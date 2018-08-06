# DIP [![Build Status](https://travis-ci.org/bibendi/dip.svg?branch=master)](https://travis-ci.org/bibendi/dip)

Docker Interaction Process

CLI utility for straightforward provisioning and interacting with an application configured by docker-compose.

DIP also contains commands for running support containers such as ssh-agent and DNS server.

## Installation

### Source and binaries

https://github.com/bibendi/dip/releases


## Docker installation

- [Ubuntu](docs/docker-ubuntu-install.md)
- [Mac OS](docs/docker-for-mac-install.md)

### Completion

#### Bash

##### Mac OS X

```sh
dip completion bash > /usr/local/etc/bash_completion.d/dip
source /usr/local/etc/bash_completion
```

#### Zsh

TODO

## Usage

```sh
  dip --help
  dip SUBCOMMAND --help
```

### dip.yml

```yml
version: '2'

environment:
  COMPOSE_EXT: development
  RAILS_ENV: development
  BUNDLE_PATH: /bundle

compose:
  files:
    - docker/docker-compose.yml
    - docker/docker-compose.$COMPOSE_EXT.yml
  project_name: bear$RAILS_ENV

interaction:
  sh:
    service: foo-app
    compose_run_options: [no-deps]

  bundle:
    service: foo-app
    command: bundle

  rake:
    service: foo-app
    command: bundle exec rake

  rspec:
    service: foo-app
    environment:
      RAILS_ENV: test
    command: bundle exec rspec

  rails:
    service: foo-app
    command: bundle exec rails
    subcommands:
      s:
        service: foo-web
        compose_method: up

  psql:
    service: foo-app
    command: psql -h pg -U postgres bear

provision:
  - docker volume create --name bundle_data
  - dip sh ./script/config_env
  - dip compose up -d foo-pg foo-redis
  - until dip sh nc -z foo-pg 5432; do echo "Waiting for foo-pg..."; sleep 5; done
  - dip bundle install
  - dip rake db:migrate --trace > /dev/null
```

### dip run

Run commands defined in `interaction` section of dip.yml

```sh
  dip run rails c
  dip run rake db:migrate
```

`run` argument can be ommited

```sh
  dip rake db:migrate
```

### dip provision

Run commands each by each from `provision` section of dip.yml

### dip compose

Run docker-compose commands that are configured according with application dip.yml

```sh
  dip compose COMMAND [OPTIONS]

  dip compose up -d redis
```

### dip ssh

Runs ssh-agent container base on https://github.com/whilp/ssh-agent with your ~/.ssh/id_rsa.
It creates a named volume `ssh_data` with ssh socket.
An applications docker-compose.yml should define environment variable `SSH_AUTH_SOCK=/ssh/auth/sock` and connect to external volume `ssh_data`.

```sh
  dip ssh add
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

### dip nginx

Runs Nginx server container based on [abakpress/nginx-proxy](https://github.com/abak-press/nginx-proxy) image. An application's docker-compose.yml should define environment variable `VIRTUAL_HOST` and `VIRTUAL_PATH` and connect to external network `frontend`.

foo-project/docker-compose.yml

```yml
version: '2'

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
version: '2'

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

### dip dns

Runs DNS server container based on https://github.com/aacebedo/dnsdock It used for container to container requests through nginx. An application's docker-compose.yml should define `dns` configuration with environment variable `$DIP_DNS` and connect to external network `frontend`. `$DIP_DNS` will be automatically assigned by dip.

```sh
  dip dns up

  cd foo-project
  dip compose exec foo-web curl http://www.bar-app.docker/api/v1/baz_service
```
