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

    pub fn success() -> LambdaResponse<String> {
        Self::builder()
            .status(200)
            .body(
                json!({
                    "success": true,
                    "message": "Account confirmed successfully.".to_string(),
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
                    "message": "Account confirmation failed".to_string(),
                    "error": error
                })
                .to_string(),
            )
            .expect("Failed to build error response body")
    }
}

#[derive(Debug, Serialize)]
pub struct ResponseError {
    pub code: u16,
    pub details: String,
}
