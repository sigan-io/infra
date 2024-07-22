use lambda_http::http::response::Builder;
use lambda_http::http::Response as LambdaResponse;
use serde::Serialize;
use serde_json::json;

pub struct Response {}

impl Response {
    fn builder() -> Builder {
        LambdaResponse::builder()
            .header("X-RateLimit-Limit", "Not Yet Implemented")
            .header("X-RateLimit-Remaning", "Not Yet Implemented")
    }

    pub fn success(data: ResponseData) -> LambdaResponse<String> {
        Self::builder()
            .status(201)
            .body(
                json!({
                    "success": true,
                    "message": "Account created successfully. A confirmation code was sent to your email.".to_string(),
                    "data": data
                })
                .to_string(),
            )
            .expect("Failed to build success response body")
    }

    pub fn error(error: ResponseError) -> LambdaResponse<String> {
        Self::builder()
            .status(error.code)
            .body(
                json!({
                    "success": false,
                    "message": "Account creation failed".to_string(),
                    "error": error
                })
                .to_string(),
            )
            .expect("Failed to build error response body")
    }
}

#[derive(Debug, Serialize)]
pub struct ResponseData {
    pub account_id: String,
    pub account_confirmed: bool,
}

#[derive(Debug, Serialize)]
pub struct ResponseError {
    pub code: u16,
    pub details: String,
}
