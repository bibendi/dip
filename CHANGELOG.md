# Changelog

## [Unreleased]

- Added Fish shell support for `dip console` shell integration: `dip console | source`
- Added `--shell` (`-s`) option to `dip console` / `dip console inject` to force the shell dialect (`bash`, `zsh`, `fish`); autodetected from `$SHELL` by default
- Fixed `dip.yml` schema validation crashing on the `json` gem 3.0+ (Ruby 3.5+): `unknown keyword: quirks_mode`
- Fixed shell integration (`dip console`) re-running `dip` on every `cd`, even within the same project — it now only reloads aliases when the resolved `dip.yml` actually changes
- Fixed `dip console inject` paying for full `dip.yml` schema validation on every shell reload; it now only reads the interaction command names
- Fixed shell integration aliasing interaction commands over shell builtins/keywords (e.g. an interaction named `jobs` silently shadowed the `jobs` builtin, which prompts like Starship call on every render); such names are now skipped with a warning instead

## [8.3.0] - 2026-05-23

- Added `preflight` hook to run commands before `dip compose`, `dip run` and `dip ktl` [#188]

## [8.2.6] - 2026-05-09

- Added automated release workflow for RubyGems publishing and GitHub Releases

## [8.2.5] - 2024-11-29

- Fix some load errors related to different gem versions being available [#184]

## [8.2.2] - 2024-11-26

- Fix: invalid regular expression `Invalid regular expression: /^[\w\-\.\:\/\s]+$/u: Invalid escape` [#180]

## [8.2.1] - 2024-11-26

- Allow more special characters in commands [#179]

## [8.2.0] - 2024-11-25

- JSON Schema validation for `dip.yml` configuration files [#176]
- New `dip validate` CLI command to manually validate configurations [#176]

## [8.1.0] - 2024-08-01

- Support for modular configuration files via `modules` directive in `dip.yml` [#173]

## [8.0.0] - 2024-03-29

- **BREAKING**: Dropped `dip nginx` and `dip dns` subcommands in favor of `dip infra`
- **BREAKING**: Dropped Docker Compose V1 support (always use `docker compose`)
- Added `dip infra` subcommand
- New example app: [outbox-example-apps](https://github.com/SberMarket-Tech/outbox-example-apps)

## [7.8.0] - 2024-02-28

- Expose current user UID as `$DIP_CURRENT_USER` environment variable [#168]

## [7.7.0] - 2023-11-07

- **BREAKING**: Dropped support for Ruby 2.5 and 2.6
- Fixed multiple nested subcommands [#165]

## [7.6.0] - 2023-05-14

- Added Docker Compose profiles support [#163]

## [7.5.0] - 2022-11-04

- Implemented kubectl support: `pod`, `entrypoint` options, `namespace` config, `dip ktl` command [#156]

## [7.4.0] - 2022-09-24

- Added `dip down -A` to shutdown all running docker compose projects [#155]

## [7.3.1] - 2022-05-07

- Use `docker compose` command when possible [#150]

## [7.3.0] - 2022-03-19

- Added ability to override compose command [#145]
- Changed default nginx proxy image to `nginxproxy/nginx-proxy` [#146]

## [7.2.0] - 2021-10-22

- Added compatibility with Docker Compose V2 [#140]

## [7.1.4] - 2021-07-16

- Fix: spaces in Compose config path caused failures [#130]

## [7.1.3] - 2021-07-14

- Fix: `shell: false` commands with arguments failed [#135]

## [7.1.2] - 2021-07-02

- Escape run args in shell mode [#132]

## [7.1.1] - 2021-06-17

- Fixed compatibility with Psych 4.0

## [7.1.0] - 2021-04-30

- Added `shell` option to command config (default: true) [#128]

## [7.0.1] - 2021-04-12

- Fixed `dns` and `ssh` commands [#122]

## [7.0.0] - 2021-03-31

- **BREAKING**: Set minimum Ruby version to 2.5
- Implemented command execution through shell. Supports complex commands: `command: echo $(pwd)`
- Don't replace non-environment variables
- Allow running commands on the host (without `service` key)
- Removed Travis CI, switched to GitHub Actions
- Lint with Standard
- No more compiled binary releases

## [6.1.0] - 2020-08-19

- New parameter for `dip ssh add` command [#89]

## [6.0.0] - 2020-05-17

- **BREAKING**: Set minimum Ruby version to 2.4 [#85]
- Don't raise exception when some main config key is missing [#84]
- Allow `--project-directory` for docker-compose command [#87]

## [5.0.0] - 2020-02-24

- **BREAKING**: `docker-compose` config file paths are now relative to `dip.yml` directory (not working directory)
- Added `ConfigFinder` to traverse parent directories for `dip.yml` discovery [#79]
- Added `$DIP_WORK_DIR_REL_PATH` special environment variable
- Added ability to add interaction commands coinciding with Ruby keywords
- Added ability to publish container's ports: `dip run -p 3000:3000 ...`

## [4.2.0] - 2019-11-06

- Added CLI options allowing to mount SSL certificates into an nginx container

## [4.1.0] - 2019-10-23

- Added `default_args` key to command schema

## [4.0.1] - 2019-10-22

- Fixed bug with shorthanded run commands

## [4.0.0] - 2019-10-22

- **BREAKING**: Dropped support for Ruby < 2.3
- Added endless nesting of subcommands
- Added `description` key to commands
- Added `dip ls` command
- Added version check (`version` key in `dip.yml`)
- Added nested compose options (`compose: { method:, run_options: }`)
- Backward compatibility for `compose_run_method` / `compose_run_options`

## [3.8.3] - 2019-07-24

- Fixed regression when passing env vars through argv (e.g. `dip VERSION=20190101 rake db:migrate:down`)

## [3.8.2] - 2019-07-04

- Dip now provided as both a Ruby gem and a compiled binary (via ruby-packer)

## [3.7.2] - 2019-07-03

- Let the shell determine Dip's bin path

## [3.7.1] - 2019-07-02

- Fix showing help banners for `compose` and `run` commands

## [3.7.0] - 2019-07-02

- Add ability to inject aliases into Bash: `eval "$(dip console)"`

## [3.6.1] - 2019-07-02

- Don't use run vars when running containers in `up` mode

## [3.6.0] - 2019-06-26

- Added ability to override main config via `dip.override.yml`

## [3.5.0] - 2018-10-17

- Added prompt integration into ZSH agnoster theme

## [3.4.2] - 2018-10-15

- Fixed bugs with manually passed volatile environment variables

## [3.4.0] - 2018-10-13

- Determine manually passed environment variables in shell mode
- **BREAKING**: Changed shell mode entry method

## [3.3.0] - 2018-10-12

- Added integration into ZSH shell: `source $(dip console)`

## [3.2.3] - 2018-10-08

- Fixed `YAML.safe_load` compatibility with Ruby < 2.5

## [3.2.2] - 2018-10-08

- Raises error unless config file found
- Refactored tests

## [3.2.1] - 2018-10-06

- Better config path detection

## [3.2.0] - 2018-09-28

- Added `dip down` command (shortener for `docker-compose down`)

## [3.1.0] - 2018-09-27

- Added `dip up` command
- Correct Thor subcommand usage; no more monkey patching

## [3.0.0] - 2018-09-25

- **BREAKING**: Complete rewrite from Crystal to Ruby
- 100% compatible with previous versions

## [2.2.2] - 2018-08-20

- Use not only String for env vars (second try)

## [2.2.1] - 2018-08-20

- Pass first arg vars to compose-run as environment vars

## [2.2.0] - 2018-08-19

- Use not only String for env vars
- Remove redundant env vars when running compose run
- Handle ENV vars from the first argument
- Run compose only with existing files

## [2.1.0] - 2018-08-07

- Added `dip ssh restart`
- Automatic builds of binaries in Travis-CI
- Crystal 0.25.1 with static linking

## [2.0.0] - 2018-04-11

- Run dnsdock on a random port by default
- Added `DIP_DNS` environment variable
- Added `dip dns ip` command
- Removed `--ip` option from dns and nginx (use `--publish`)
- Added `--net` option for `dns up`
- Added `--domain` option for nginx

## [1.1.0] - 2018-04-05

- Change default nginx-proxy image
- Update installation instructions

## [1.0.2] - 2017-12-05

- Run ssh agent without `--rm` from right place

## [1.0.1] - 2017-12-05

- Run ssh agent without `--rm`

## [1.0.0] - 2017-12-05

- Add options for dns: name, domain, image
- Change default network name for nginx to frontend
- Add `compose_method` / `compose_run_options` to config

## [0.11.1] - 2017-11-20

- Add docs for Docker for Mac
- Don't remove network on nginx down

## [0.11.0] - 2017-11-14

- Run ssh agent with autoremove
- Add nginx proxy command

## [0.10.0] - 2017-05-24

- Allow to setup compose run options [#16]

## [0.9.0] - 2017-02-14

- Add shell completion

## [0.8.1] - 2016-11-17

- Don't panic unless `dip.yml` exists

## [0.8.0] - 2016-10-14

- Check version of `dip.yml`
- Fix ssh status command
- Fix ssh up (add) command

## [0.7.0] - 2016-10-12

- Add `environment` section for commands and subcommands
- Substitute env vars in all commands
- Remove ssh-agent after container stopped

## [0.6.0] - 2016-10-11

- Add help for top commands
- Refactor compose command
- Run build scripts with force overwrite

## [0.5.0] - 2016-10-10

- Add `ssh status` command
- Parse env vars in environment

## [0.4.0] - 2016-10-07

- Replace env vars in provision

## [0.3.1] - 2016-10-07

- Fix misstype in run command
- Add build scripts

## [0.3.0] - 2016-10-07

- Add run command
- Add provision command
- Run compose with inner env vars
- Make compose section optional

## [0.2.0] - 2016-10-06

- Fix executing command with argv
- Show executing command with `DIP_DEBUG=1`
- Add version subcommand

## [0.1.0] - 2016-10-06

- First Release!
- Transferring commands to docker-compose with environment variables
- Running ssh-agent container
- Running dns server container
