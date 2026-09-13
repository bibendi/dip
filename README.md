[![Gem Version](https://badge.fury.io/rb/dip.svg)](https://badge.fury.io/rb/dip)
[![Build Status](https://github.com/bibendi/dip/actions/workflows/ci.yml/badge.svg)](https://github.com/bibendi/dip/actions/workflows/ci.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/d0dca854f0930502f7b3/maintainability)](https://codeclimate.com/github/bibendi/dip/maintainability)

<img src="https://raw.githubusercontent.com/bibendi/dip/master/.github/logo.png" alt="dip logo" height="140" />

The dip is a CLI dev–tool that provides native-like interaction with a Dockerized application. It gives the feeling that you are working without using mind-blowing commands to run containers.

<a href="https://evilmartians.com/?utm_source=dip">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" height="80" /></a>

## Presentations and examples

- [Local development with Docker containers](https://slides.com/bibendi/dip)
- [Dockerized Ruby on Rails application](https://github.com/Kuper-Tech/outbox-example-apps)
- Dockerized Node.js application: [one](https://github.com/bibendi/twinkle.js), [two](https://github.com/bibendi/yt-graphql-react-event-booking-api)
- [Dockerized Ruby gem](https://github.com/bibendi/schked)
- [Dockerizing Ruby and Rails development](https://evilmartians.com/chronicles/ruby-on-whales-docker-for-ruby-rails-development)
- [Reusable development containers with Docker Compose and Dip](https://evilmartians.com/chronicles/reusable-development-containers-with-docker-compose-and-dip)

[![asciicast](https://asciinema.org/a/210236.svg)](https://asciinema.org/a/210236)

## Quick start with AI

[dip-skill](https://github.com/kalashnikovisme/dip-skill) helps you quickly configure a `dip` environment for your project. It detects the tech stack and bootstraps `dip.yml`, compose files, and Dockerfiles.

```sh
npx skills add kalashnikovisme/dip-skill
```

## Installation

```sh
gem install dip
```

### Integration with shell

Dip can be injected into the current shell so that interaction commands (and `compose`, `up`, `stop`, `down`, `build`, `provision`) become available without the `dip` prefix. **Bash**, **ZSH**, and **Fish** are supported.

Add the matching line to your shell startup file so the integration is loaded in every session:

```sh
# Bash — ~/.bashrc or ~/.bash_profile
eval "$(dip console)"
```

```sh
# ZSH — ~/.zshrc
eval "$(dip console)"
```

```fish
# Fish — ~/.config/fish/config.fish
dip console | source
```

The target shell is autodetected from the `$SHELL` environment variable, so the snippets above work as-is. If autodetection is wrong (for example, you run Fish but `$SHELL` still points to Bash), force the dialect explicitly:

```sh
eval "$(dip console --shell zsh)"     # Bash / ZSH
dip console --shell fish | source     # Fish
```

`--shell` accepts `bash`, `zsh`, or `fish` (`bash` and `zsh` produce the same POSIX output).

**IMPORTANT**: Beware of possible collisions with local tools. One particular example is supporting both local and Docker frontend build tools, such as Yarn. If you want some developer to run `yarn` locally and other to use Docker for that, you should either avoid adding the `yarn` command to the `dip.yml` or avoid using the shell integration for hybrid development.

After that we can type commands without `dip` prefix. For example:

```sh
<run-command> *any-args
compose *any-compose-arg
up <service>
ktl *any-kubectl-arg
provision
```

When we change the current directory, all shell aliases are automatically removed. When we enter a directory that has a `dip.yml` file (in it or in a parent), the aliases are renewed. This is wired through the shell's directory-change hook — `chpwd_functions` on ZSH, a `cd`/`pushd`/`popd` wrapper on Bash, and a `--on-variable PWD` handler on Fish. The hook resolves the applicable `dip.yml` itself (no `dip` process involved) and only actually reloads when that path changes, so `cd`ing around inside the same project doesn't re-run `dip` on every prompt.

Also, in shell mode Dip tries to determine manually passed environment variables. For example:

```sh
VERSION=20180515103400 rails db:migrate:down
```

Once the startup snippet is in place, the integration is applied automatically every time you open your terminal.

#### How it works

`dip console` prints a bootstrap script that defines three helpers:

- `dip_inject` — evaluates `dip console inject`, which emits one shell function per interaction command plus the built-in `compose`/`up`/`stop`/`down`/`build`/`provision` wrappers. An interaction command whose name collides with a shell builtin/keyword (`jobs`, `test`, `read`, `set`, …) is skipped, with a warning on stderr — run it as `dip <name>` instead, or rename it.
- `dip_clear` — removes the functions previously injected (regenerated on every inject so it always matches the current `dip.yml`).
- `dip_reload` — runs `dip_clear` then `dip_inject`; also bound to the directory-change hook, which calls it only when the resolved `dip.yml` path actually changed.

The bootstrap also exports `DIP_SHELL=1`, `DIP_EARLY_ENVS` (the list of variables present at load time, used to detect manually passed env vars), and `DIP_PROMPT_TEXT` (`ⅆ`). On ZSH with the `agnoster` theme, `DIP_PROMPT_TEXT` is added as a prompt segment; other shells and themes are left untouched.

You can force a reload at any time by running `dip_reload` (useful after editing `dip.yml`).

## Usage

```sh
dip --help
dip SUBCOMMAND --help
```

### dip.yml

The configuration is loaded from `dip.yml` file. It may be located in a working directory, or it will be found in the nearest parent directory up to the file system root. If a `dip.override.yml` file exists nearby, it will be merged into the main config.

Also, in some cases, you may want to change the default config path by providing an environment variable `DIP_FILE`.

Below is an example of a real config.
The schema is defined in `schema.json` and can be validated with `dip validate`.
Also, you can check out examples at the top.

```yml
# Required minimum dip version
version: '8.0'

environment:
  COMPOSE_EXT: development
  STAGE: "staging"

compose:
  files:
    - docker/docker-compose.yml
    - docker/docker-compose.$COMPOSE_EXT.yml
    - docker/docker-compose.$DIP_OS.yml
  project_name: bear

kubectl:
  namespace: rocket-$STAGE

interaction:
  shell:
    description: Open the Bash shell in app's container
    service: app
    command: bash
    compose:
      run_options: [no-deps]

  bundle:
    description: Run Bundler commands
    service: app
    command: bundle

  rake:
    description: Run Rake commands
    service: app
    command: bundle exec rake

  rspec:
    description: Run Rspec commands
    service: app
    environment:
      RAILS_ENV: test
    command: bundle exec rspec

  rails:
    description: Run Rails commands
    service: app
    command: bundle exec rails
    subcommands:
      s:
        description: Run Rails server at http://localhost:3000
        service: web
        compose:
          run_options: [service-ports, use-aliases]

  stack:
    description: Run full stack (server, workers, etc.)
    runner: docker_compose
    compose:
      profiles: [web, workers]

  sidekiq:
    description: Run sidekiq in background
    service: worker
    compose:
      method: up
      run_options: [detach]

  psql:
    description: Run Postgres psql console
    service: app
    default_args: db_dev
    command: psql -h pg -U postgres

  k:
    description: Run commands in Kubernetes cluster
    pod: svc/rocket-app:app-container
    entrypoint: /env-entrypoint
    subcommands:
      bash:
        description: Get a shell to the running container
        command: /bin/bash
      rails:
        description: Run Rails commands
        command: bundle exec rails
      kafka-topics:
        description: Manage Kafka topics
        pod: svc/rocket-kafka
        command: kafka-topics.sh --zookeeper zookeeper:2181

  setup_key:
    description: Copy key
    service: app
    command: cp `pwd`/config/key.pem /root/keys/
    shell: false # you can disable shell interpolations on the host machine and send the command as is

  clean_cache:
    description: Delete cache files on the host machine
    command: rm -rf $(pwd)/tmp/cache/*

provision:
  - dip compose down --volumes
  - dip clean_cache
  - dip compose up -d pg redis
  - dip bash -c ./bin/setup

preflight:
  - ./bin/check-credentials
  - test -f .env
```

`preflight` is an array of shell commands that dip runs before any command that touches a running container or cluster: `dip compose ...` (and its aliases `dip up`, `dip build`, `dip stop`, `dip down`), `dip ktl ...`, and `dip run ...` (including the interaction shorthand `dip <name>`). If any command exits non-zero, dip aborts before the underlying operation runs. Useful for verifying credentials are present, required files exist, env vars are set, etc.

Not triggered by `dip down --all` (cross-project teardown), `dip ssh`, `dip infra`, or `dip provision`.

### Predefined environment variables

#### $DIP_OS

Current OS name (e.g. `linux`, `darwin`, `freebsd`, and so on). Sometimes it may be useful to have one common `docker-compose.yml` and OS-dependent Compose configs.

#### $DIP_WORK_DIR_REL_PATH

Relative path from the current directory to the nearest directory where a Dip's config is found. It is useful when you need to mount a specific local directory to a container along with ability to change its working dir. For example:

```
- project_root
  |- dip.yml (1)
  |- docker-compose.yml (2)
  |- sub-project-dir
     |- your current directory is here <<<
```

```yml
# dip.yml (1)
environment:
  WORK_DIR: /app/${DIP_WORK_DIR_REL_PATH}
```

```yml
# docker-compose.yml (2)
services:
  app:
    working_dir: ${WORK_DIR:-/app}
```

```sh
cd sub-project-dir
dip run bash -c pwd
```

returned is `/app/sub-project-dir`.

#### $DIP_CURRENT_USER

Exposes the current user ID (UID). It is useful when you need to run a container with the same user as the host machine. For example:

```yml
# dip.yml (1)
environment:
  UID: ${DIP_CURRENT_USER}
```

```yml
# docker-compose.yml (2)
services:
  app:
    image: ruby
    user: ${UID:-1000}
```

The container will run using the same user ID as your host machine.

### Modules

Modules are defined as an array in the `modules` section of dip.yml. Module files are stored in the `.dip` subdirectory next to dip.yml.

The main purpose of modules is to improve maintainability for a group of projects.
Imagine having multiple gems which are managed with dip, each of them has the same commands, so to change one command in dip you need to update all gems individualy.

With `modules` you can define a group of modules for dip.

For example having setup as this:

```yml
# ./dip.yml
modules:
 - sasts
 - rails

...
```

```yml
# ./.dip/sasts.yml
interaction:
  brakeman:
    description: Check brakeman sast
    command: docker run ...
```

```yml
# ./.dip/rails.yml
interaction:
  annotate:
    description: Run annotate command
    service: backend
    command: bundle exec annotate
```

Will be expanded to:

```yml
# resultant configuration
interaction:
  brakeman:
    description: Check brakeman sast
    command: docker run ...
  annotate:
    description: Run annotate command
    service: backend
    command: bundle exec annotate
```

Imagine `.dip` to be a submodule so it can be managed only in one place.

If you want to override module command, you can redefine it in dip.yml

```yml
# ./dip.yml
modules:
 - sasts

interaction:
  brakeman:
    description: Check brakeman sast
    command: docker run another-image ...
```

```yml
# ./.dip/sasts.yml
interaction:
  brakeman:
    description: Check brakeman sast
    command: docker run some-image ...
```

Will be expanded to:

```yml
# resultant configuration
interaction:
  brakeman:
    description: Check brakeman sast
    command: docker run another-image ...
```

Nested modules are not supported.

### dip run

Run commands defined within the `interaction` section of dip.yml

A command will be executed by the specified runner. You can set the runner explicitly via the `runner` key (e.g. `runner: docker_compose`). Otherwise dip picks the runner automatically:

- `docker compose` runner — used when the `service` option is defined.
- `kubectl` runner — used when the `pod` option is defined.
- `local` runner — used when the previous ones are not defined.

```sh
dip run rails c
dip run rake db:migrate
```

Also, `run` argument can be omitted

```sh
dip rake db:migrate
```

You can pass in a custom environment variable into a container:

```sh
dip VERSION=12352452 rake db:rollback
```

Use options `-p, --publish=[]` if you need to additionally publish a container's port(s) to the host unless this behaviour is not configured at dip.yml:

```sh
dip run -p 3000:3000 bundle exec rackup config.ru
```

You can also override docker compose command by passing `DIP_COMPOSE_COMMAND` if you wish. For example if you want to use [`mutagen-compose`](https://mutagen.io/documentation/orchestration/compose) run `DIP_COMPOSE_COMMAND=mutagen-compose dip run`.

If you want to persist that change you can specify command in `compose` section of dip.yml :

```yml
compose:
  command: mutagen-compose

```

### dip ls

List all available run commands.

```sh
dip ls

bash     # Open the Bash shell in app's container
rails    # Run Rails command
rails s  # Run Rails server at http://localhost:3000
```

### dip provision

Run commands each by each from `provision` section of dip.yml

### dip compose

Run Docker Compose commands that are configured according to the application's dip.yml:

```sh
dip compose COMMAND [OPTIONS]

dip compose up -d redis
```

### dip infra

Runs shared Docker Compose services that are used by the current application. Useful for microservices.

There are several official infrastructure services available:
- [dip-postgres](https://github.com/bibendi/dip-postgres)
- [dip-kafka](https://github.com/bibendi/dip-kafka)
- [dip-nginx](https://github.com/bibendi/dip-nginx)

```yaml
# dip.yml
infra:
  foo:
    git: https://github.com/owner/foo.git
    ref: latest # default, optional
  bar:
    path: ~/path/to/bar
```

Repositories will be pulled to a `~/.dip/infra` folder. For example, for the `foo` service it would be like this: `~/.dip/infra/foo/latest` and clonned with the following command: `git clone -b <ref> --single-branch <git> --depth 1`.

Available CLI commands:

- `dip infra update` pulls updates from sources
- `dip infra up` starts all infra services
- `dip infra up -n kafka` starts a specific infra service
- `dip infra down` stops all infra services
- `dip infra down -n kafka` stops a specific infra service

### dip ktl

Run kubectl commands that are configured according to the application's dip.yml:

```sh
dip ktl COMMAND [OPTIONS]

STAGE=some dip ktl get pods
```

### dip ssh

Runs ssh-agent container based on https://github.com/whilp/ssh-agent with your ~/.ssh/id_rsa.
It creates a named volume `ssh_data` with ssh socket.
An application's docker-compose.yml should contain the environment variable `SSH_AUTH_SOCK=/ssh/auth/sock` and connect the external volume `ssh_data`.

```sh
dip ssh up
```

docker-compose.yml

```yml
services:
  web:
    environment:
      - SSH_AUTH_SOCK=/ssh/auth/sock
    volumes:
      - ssh-data:/ssh:ro

volumes:
  ssh-data:
    external:
      name: ssh_data
```

if you want to use non-root user you can specify UID like so:

```
dip ssh up -u 1000
```

This especially helpful if you have something like this in your docker-compose.yml:

```yml
services:
  web:
    user: "1000:1000"
```

### dip validate

Validates your dip.yml configuration against the JSON schema. The schema validation helps ensure your configuration is correct and follows the expected format.

```sh
dip validate
```

The validator will check:

- Required properties are present
- Property types are correct
- Values match expected patterns
- No unknown properties are used

If validation fails, you'll get detailed error messages indicating what needs to be fixed.

You can skip validation by setting `DIP_SKIP_VALIDATION` environment variable.

Add `# yaml-language-server: $schema=https://raw.githubusercontent.com/bibendi/dip/refs/heads/master/schema.json` to the top of your dip.yml to get schema validation in VSCode. Read more about [YAML Language Server](https://github.com/redhat-developer/vscode-yaml?tab=readme-ov-file#associating-schemas).

### dip console

Prints the shell integration script for the current shell. See [Integration with shell](#integration-with-shell) for the full setup.

```sh
dip console [--shell bash|zsh|fish]          # bootstrap script (default subcommand)
dip console inject [--shell bash|zsh|fish]   # just the command aliases
```

- `--shell` (`-s`) selects the dialect: `bash`, `zsh`, or `fish`. When omitted, it is autodetected from `$SHELL`, falling back to POSIX (Bash/ZSH) output.
- `dip console` is meant to be evaluated by your shell: `eval "$(dip console)"` for Bash/ZSH, `dip console | source` for Fish.
- `dip console inject` is called internally by the bootstrap script (via `dip_reload`); you normally don't run it by hand. It only needs the interaction command names, so it skips full `dip.yml` schema validation — run `dip validate` (or any other `dip` command) to check the file against the schema.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).
