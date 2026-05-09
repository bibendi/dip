# AGENTS.md — dip

dip is a Ruby CLI gem (Thor-based) for Dockerized development. It wraps docker-compose and kubectl commands via a `dip.yml` config.

## Commands

```sh
# Dev inside Docker (preferred — most commands require docker-compose)
dip provision          # first-time setup: copies lefthook config, cleans Gemfile.lock, installs deps
dip rspec              # run tests
dip rspec spec/path    # single file
dip rubocop            # lint
dip rubocop -a         # lint + auto-correct
dip pry                # open Pry console
dip bundle install     # add dependencies

# Direct (without Docker)
bundle exec rspec spec/path           # single test file
bundle exec rubocop                   # lint
```

## Testing

- **FakeFS** is used for filesystem isolation. Wrap filesystem-dependent tests.
- **Custom matchers** (`expected_exec`, `expected_subprocess`) stub `Kernel.exec` / `Kernel.system`:
  - Tag examples with `:runner` — shared context stubs `Dip::Command::ProgramRunner` / `SubprocessRunner` as spies.
- **Shared contexts**: `:config` (injects Dip.config), `:env` (overrides ENV around example).
- **Config fixture**: Each test gets `DIP_FILE` pointing to `spec/fixtures/empty/dip.yml` — override by setting `ENV["DIP_FILE"]` in the example.
- **Coverage**: SimpleCov enforces 90% minimum. Run `bundle exec rspec` to check.
- **Order**: Random (`--order random` in `.rspec`). No `.rspec_status` tracked in git.
- **DIP_ENV=test** is set automatically in `spec_helper.rb`.

## Config (`dip.yml`)

- Discovered by walking up from CWD to root. Accepts ERB. Merges `dip.override.yml` if present.
- `DIP_FILE` env var overrides the path. `DIP_SKIP_VALIDATION` skips schema check.
- Schema validated via `schema.json` at the repo root.

## Project structure

```
exe/dip              # entrypoint
lib/dip.rb           # main module
lib/dip/cli.rb       # Thor CLI definition
lib/dip/commands/    # command implementations
lib/dip/commands/runners/  # DockerComposeRunner, KubectlRunner, LocalRunner
lib/dip/config.rb    # YAML+ERB config loader
spec/fixtures/       # dip.yml fixtures for tests
schema.json          # JSON Schema for dip.yml
```

## Notable

- **No Gemfile.lock** in git (in `.gitignore`).
- Required Ruby >= 2.7. Tested on 2.7–3.3 in CI.
- Pre-commit via lefthook: `bundle exec rubocop -A {staged_files}` + re-adds.
- Dependencies: thor, json-schema, public_suffix.
