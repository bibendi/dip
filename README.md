# DIP [![Build Status](https://travis-ci.org/bibendi/dip.svg?branch=master)](https://travis-ci.org/bibendi/dip)

Docker Interaction Process

CLI utility for straightforward provisioning and interacting with an application configured by docker-compose.

DIP also contains commands for running support containers such as ssh-agent and DNS server.

## Installation

### Source and binaries

https://github.com/bibendi/dip/releases

### Packages

#### Mac OS X

```
brew tap bibendi/dip
brew install dip
```

#### Ubuntu

TODO

## Usage

```sh
dip --help
dip SUBCOMMAND --help
```

### dip.yml

```yml
version: '1'

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
    service: app

  bundle:
    service: app
    command: bundle

  rake:
    service: app
    command: bundle exec rake

  rspec:
    service: app
    environment:
      RAILS_ENV: test
    command: bundle exec rspec

  rails:
    service: app
    subcommands:
      s:
        service: web

      c:
        command: bundle exec rails c

  psql:
    service: app
    command: psql -h pg -U postgres bear

provision:
  - docker volume create --name bundle_data
  - dip sh ./script/config_env
  - dip compose up -d pg redis
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

### dip dns

Runs DNS server container based on https://github.com/aacebedo/dnsdock

```sh
dip dns up
```

## Docker installation

- [Ubuntu](docs/docker-ubuntu-install.md)
- [MacOS docker-machine xhyve](docs/docker-xhyve-install.md)
- [MacOS dlite](docs/docker-dlite-install.md)
