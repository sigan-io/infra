use regex_lite::Regex;
use serde::Deserialize;
use validator::{Validate, ValidationError};

#[derive(Debug, Deserialize, Validate)]
pub struct Payload {
    #[validate(
        required(message = "Email is required"),
        email(message = "Email is not valid"),
        length(max = 254, message = "Email must be less than 254 characters")
    )]
    pub email: Option<String>,

    #[validate(
        required(message = "Password is required"),
        length(
            min = 8,
            max = 64,
            message = "Password must be between 8 and 64 characters"
        ),
        custom(
            function = "validate_password",
            message = "Password must contain at least one lowercase letter, one uppercase letter, one number, and one special character"
        )
    )]
    pub password: Option<String>,
}

fn validate_password(password: &str) -> Result<(), ValidationError> {
    let has_lowercase = password.chars().any(char::is_lowercase);
    if !has_lowercase {
        return Err(ValidationError::new(
            "Password must contain at least one lowercase letter",
        ));
    }

    let has_uppercase = password.chars().any(char::is_uppercase);
    if !has_uppercase {
        return Err(ValidationError::new(
            "Password must contain at least one uppercase letter",
        ));
    }

    let has_number = password.chars().any(char::is_numeric);
    if !has_number {
        return Err(ValidationError::new(
            "Password must contain at least one number",
        ));
    }

    let has_special_char = Regex::new(r"[^a-zA-Z\d]").unwrap().is_match(password);
    if !has_special_char {
        return Err(ValidationError::new(
            "Password must contain at least one special character",
        ));
    }

    Ok(())
}
