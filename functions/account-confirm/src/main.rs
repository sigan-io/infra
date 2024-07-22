mod payload;
mod response;

use aws_config::BehaviorVersion;
use aws_sdk_cognitoidentityprovider::Client as CognitoClient;
use lambda_http::{run, service_fn, Error, IntoResponse, Request, RequestPayloadExt};
use payload::Payload;
use response::{Response, ResponseError};
use validator::Validate;

#[tokio::main]
async fn main() -> Result<(), Error> {
    let config = aws_config::load_defaults(BehaviorVersion::latest()).await;
    let client = CognitoClient::new(&config);
    let client_ref = &client;

    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        // disable printing the name of the module in every log line.
        .with_target(false)
        // disabling time is handy because CloudWatch will add the ingestion time.
        .without_time()
        .init();

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

    let (email, code) = match payload.validate() {
        Ok(_) => (
            payload.email.expect("Failed to extract email"),
            payload.code.expect("Failed to extract confirmation code"),
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

    /* Call Cognito API to confirm account */

    let cognito_response = client
        .confirm_sign_up()
        .client_id(std::env::var("USER_POOL_CLIENT_ID")?)
        .username(email)
        .confirmation_code(code)
        .send()
        .await;

    /* Process Cognito API response */

    match cognito_response {
        Ok(_) => {
            let response = Response::success();

            Ok(response)
        }
        Err(error) => {
            let error = error.into_service_error();

            if error.is_code_mismatch_exception() {
                return Ok(Response::error(ResponseError {
                    code: 401,
                    details: "The code you entered is not valid".into(),
                }));
            }

            if error.is_not_authorized_exception()
                && error.to_string().contains("Current status is CONFIRMED")
            {
                return Ok(Response::error(ResponseError {
                    code: 401,
                    details: "The account has already been confirmed".into(),
                }));
            }

            Ok(Response::error(ResponseError {
                code: 500,
                details: error.to_string(),
            }))
        }
    }
}
