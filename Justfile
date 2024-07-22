### Default Just Command ###

@_default:
  just --list --unsorted

### Cargo Lambda ###

@watch:
  cargo lambda watch --env-vars USER_POOL_CLIENT_ID=REDACTED

@invoke function="":
  cargo lambda invoke --data-file functions/account-create/fixtures/events/account-create.json {{function}} | jq '.body |= fromjson'

@build target="":
  if [ "{{target}}" != "" ]; then \
    cargo lambda build --release --arm64 --output-format zip --package {{target}}; \
  else \
    just build account-create; \
    just build account-confirm; \
  fi

## Tofu ###

@init workspace="main":
  tofu -chdir={{workspace}} init

@plan workspace="main":
  tofu -chdir={{workspace}} plan

@apply workspace="main":
  tofu -chdir={{workspace}} apply

@destroy workspace="main":
  tofu -chdir={{workspace}} destroy

@refresh workspace="main":
  tofu -chdir={{workspace}} refresh
