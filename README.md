# Internal AWS Infrastructure

## Requirements

You'll need to install the following software in order to use this repo:

- [OpenTofu](https://opentofu.org/)
- [Rust](https://www.rust-lang.org/)
- [Cargo Lambda](https://www.cargo-lambda.info/)

## Naming Conventions

### Terraform Identifiers
- Must be snakecase.
- Must be prefixed with `sigan_` if they are part of Sigan's core infrastructure. This **does not** apply to Sigan's *security groups*.
- Must be named according to the main resource. (E.g. an API Gateway would be named `sigan_api_gateway`, and it's deployment and stage would also be named `sigan_api_gateway`)

### Files and Directories
- Must be snakecase to be consistent with Terraform identifiers for modules.

### Buckets AWS Identifiers
- Must be prefixed with `sigan-` to prevent conflicts with existing AWS buckets (they need to be unique between all AWS accounts).