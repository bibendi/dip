[![Gem Version](https://badge.fury.io/rb/dip.svg)](https://badge.fury.io/rb/dip)
[![Build Status](https://github.com/bibendi/dip/workflows/Ruby/badge.svg?branch=master)](https://github.com/bibendi/dip/actions?query=branch%3Amaster)
[![Maintainability](https://api.codeclimate.com/v1/badges/d0dca854f0930502f7b3/maintainability)](https://codeclimate.com/github/bibendi/dip/maintainability)

# DIP

Docker Interaction Program.

Development-environment CLI program providing the native-like interaction with a Dockerized application. It creates the feeling that you are working without mind-blowing commands to run the containers.

<a href="https://evilmartians.com/?utm_source=dip">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" height="80" /></a>

## Presentations and examples

- [Local development with Docker containers](https://slides.com/bibendi/dip)
- Dockerized Ruby on Rails applications: [one](https://github.com/lewagon/rails-k8s-demo), [two](https://github.com/bibendi/dip-example-rails), [three](https://github.com/evilmartians/evil_chat)
- Dockerized Node.js application: [one](https://github.com/bibendi/twinkle.js), [two](https://github.com/bibendi/yt-graphql-react-event-booking-api)
- [Dockerized Ruby gem](https://github.com/bibendi/schked)
- [Dockerizing Ruby and Rails development](https://evilmartians.com/chronicles/ruby-on-whales-docker-for-ruby-rails-development)
- [Reusable development containers with Docker Compose and Dip](https://evilmartians.com/chronicles/reusable-development-containers-with-docker-compose-and-dip)

[![asciicast](https://asciinema.org/a/210236.svg)](https://asciinema.org/a/210236)

## Integration with shell

Dip can be injected into the current shell (ZSH or Bash).

```sh
eval "$(dip console)"
```

**IMPORTANT**: Beware of possible collisions with local tools. One particular example is supporting both local and Docker frontend build tools, such as Yarn. If you want some developer to run `yarn` locally and other to use Docker for that, you should either avoid adding the `yarn` command to the `dip.yml` or avoid using the shell integration for hybrid development.

After that we can type commands without `dip` prefix. For example:

```sh
<run-command> *any-args
compose *any-compose-arg
up <service>
ktl *any-kubectl-arg
provision
```

When we change the current directory, all shell aliases will be automatically removed. But when we enter back into a directory with a `dip.yml` file, then shell aliases will be renewed.

Also, in shell mode Dip is trying to determine manually passed environment variables. For example:

```sh
VERSION=20180515103400 rails db:migrate:down
```

You could add this `eval` at the end of your `~/.zshrc`, or `~/.bashrc`, or `~/.bash_profile`.
After that, it will be automatically applied when you open your preferred terminal.

## Installation

```sh
gem install dip
```

The compiled binary is no more provided since version 7, because of new version of [Ruby Packer](https://github.com/pmq20/ruby-packer) not released for a long time with recent Ruby version. Also there was a lot of work to prepare each release of Dip for MacOS version.

## Usage

```sh
dip --help
dip SUBCOMMAND --help
```

### dip.yml

The configuration is loaded from `dip.yml` file. It may be located in a working directory, or it will be found in the nearest parent directory up to the file system root. If nearby places `dip.override.yml` file, it will be merged into the main config.

Also, in some cases, you may want to change the default config path by providing an environment variable `DIP_FILE`.

Below is an example of a real config.
Config file reference will be written soon.
Also, you can check out examples at the top.

```yml
# Required minimum dip version
version: '7.7'

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
```

### Predefined environment variables

#### $DIP_OS

Current OS architecture (e.g. `linux`, `darwin`, `freebsd`, and so on). Sometime it may be useful to have one common `docker-compose.yml` and OS-dependent Compose configs.

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


### dip run

Run commands defined within the `interaction` section of dip.yml

A command will be executed by specified runner. Dip has three types of them:

- `docker-compose` runner — used when the `service` option is defined.
- `kubectl` runner — used when the `pod` option is defined.
- `local` runner — used when the previous ones are not defined.

If you are still using `docker-compose` binary (i.e., prior to Compose V2 changes), a command would be run through it. You can disable using of Compose V2 by passing an environment variable `DIP_COMPOSE_V2=false dip run`.

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

Run docker-compose commands that are configured according to the application's dip.yml:

```sh
dip compose COMMAND [OPTIONS]

dip compose up -d redis
```

### dip ktl

Run kubectl commands that are configured according to the application's dip.yml:

```sh
dip ktl COMMAND [OPTIONS]

STAGE=some dip ktl get pods
```

### dip ssh

Runs ssh-agent container based on https://github.com/whilp/ssh-agent with your ~/.ssh/id_rsa.
It creates a named volume `ssh_data` with ssh socket.
An application's docker-compose.yml should contains environment variable `SSH_AUTH_SOCK=/ssh/auth/sock` and connects to external volume `ssh_data`.

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

```
services:
  web:
    user: "1000:1000"

```

### dip nginx

Runs Nginx server container based on [nginxproxy/nginx-proxy](https://github.com/nginx-proxy/nginx-proxy) image. An application's docker-compose.yml should contain environment variable `VIRTUAL_HOST` and `VIRTUAL_PATH` and connects to external network `frontend`.

foo-project/docker-compose.yml

```yml
services:
  foo-web:
    image: company/foo_image
    environment:
      - VIRTUAL_HOST=*.bar-app.docker
      - VIRTUAL_PATH=/
    networks:
      - default
      - frontend
    dns: $DIP_DNS

networks:
  frontend:
    external:
      name: frontend
```

baz-project/docker-compose.yml

```yml
services:
  baz-web:
    image: company/baz_image
    environment:
      - VIRTUAL_HOST=*.bar-app.docker
      - VIRTUAL_PATH=/api/v1/baz_service,/api/v2/baz_service
    networks:
      - default
      - frontend
    dns: $DIP_DNS

networks:
  frontend:
    external:
      name: frontend
```

```sh
dip nginx up
cd foo-project && dip compose up
cd baz-project && dip compose up
curl www.bar-app.docker/api/v1/quz
curl www.bar-app.docker/api/v1/baz_service/qzz
```

#### Pass SSL certificates

```sh
dip nginx up -c $HOME/ssl_certificates
```

#### Publish more than one port to localhost

Just pass a list, separated by a space:

```sh
dip nginx up -p 80:80 443:443
```

### dip dns

Runs a DNS server container based on https://github.com/aacebedo/dnsdock. It is used for container to container requests through Nginx. An application's docker-compose.yml should define `dns` configuration with environment variable `$DIP_DNS` and connect to external network `frontend`. `$DIP_DNS` will be automatically assigned by dip.

```sh
dip dns up

cd foo-project
dip compose exec foo-web curl http://www.bar-app.docker/api/v1/baz_service
```

## Changelog

https://github.com/bibendi/dip/releases
