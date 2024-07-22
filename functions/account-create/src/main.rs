mod payload;
mod response;

use aws_config::BehaviorVersion;
use aws_sdk_cognitoidentityprovider::Client as CognitoClient;
use lambda_http::{run, service_fn, Error, IntoResponse, Request, RequestPayloadExt};
use payload::Payload;
use response::{Response, ResponseData, ResponseError};
use validator::Validate;

#[tokio::main]
async fn main() -> Result<(), Error> {
    let config = aws_config::load_defaults(BehaviorVersion::latest()).await;
    let client = CognitoClient::new(&config);
    let client_ref = &client;

    let function = service_fn(|event| function_handler(event, client_ref));

    run(function).await
}

async fn function_handler(
    event: Request,
    client: &CognitoClient,
) -> Result<impl IntoResponse, Error> {
    let payload = event.payload::<Payload>()?;

    /* Validate Payload */

    let payload = match payload {
        Some(payload) => payload,
        None => {
            let response = Response::error(ResponseError {
                code: 400,
                details: "Payload is empty".into(),
            });

            return Ok(response);
        }
    };

    let (email, password) = match payload.validate() {
        Ok(_) => (
            payload.email.expect("Failed to extract email"),
            payload.password.expect("Failed to extract password"),
        ),
        Err(validation_errors) => {
            let field_errors = validation_errors
                .field_errors()
                .into_values()
                .flatten()
                .collect::<Vec<_>>();

            let error_message = field_errors[0].to_string();
            let response = Response::error(ResponseError {
                code: 400,
                details: error_message,
            });

            return Ok(response);
        }
    };

    /* Call Cognito API to create account */

    let cognito_response = client
        .sign_up()
        .client_id(std::env::var("USER_POOL_CLIENT_ID")?)
        .username(email)
        .password(password)
        .send()
        .await;

    /* Process Cognito API response */

    match cognito_response {
        Ok(data) => {
            let account_id = data.user_sub();
            let account_confirmed = data.user_confirmed();

            let response = Response::success(ResponseData {
                account_id: account_id.into(),
                account_confirmed,
            });

            Ok(response)
        }
        Err(error) => {
            let error = error.into_service_error();

            if error.is_username_exists_exception() {
                return Ok(Response::error(ResponseError {
                    code: 400,
                    details: "Username already exists".into(),
                }));
            }

            Ok(Response::error(ResponseError {
                code: 500,
                details: error.to_string(),
            }))
        }
    }
}
