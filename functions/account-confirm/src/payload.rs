use serde::Deserialize;
use validator::Validate;

#[derive(Debug, Deserialize, Validate)]
pub struct Payload {
    #[validate(
        required(message = "Email is required"),
        email(message = "Email is not valid"),
        length(max = 254, message = "Email must be less than 254 characters")
    )]
    pub email: Option<String>,

    #[validate(required(message = "Confirmation code is required"))]
    pub code: Option<String>,
}
