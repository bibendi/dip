[![Gem Version](https://badge.fury.io/rb/dip.svg)](https://badge.fury.io/rb/dip)
[![Build Status](https://travis-ci.org/bibendi/dip.svg?branch=master)](https://travis-ci.org/bibendi/dip)
[![Maintainability](https://api.codeclimate.com/v1/badges/d0dca854f0930502f7b3/maintainability)](https://codeclimate.com/github/bibendi/dip/maintainability)

# DIP

Docker Interaction Process

A command-line utility that gives the "native" interaction with applications configured with Docker Compose. It is for local development only. In practice, it creates the feeling that you work without containers.

<a href="https://evilmartians.com/?utm_source=dip">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

## Presentations and examples

- [Local development with Docker containers](https://slides.com/bibendi/dip)
- [Dockerized Ruby on Rails application](https://github.com/bibendi/dip-example-rails)
- [Dockerized Node.js application](https://github.com/bibendi/yt-graphql-react-event-booking-api)
- [Dockerized Ruby gem](https://github.com/bibendi/schked)

[![asciicast](https://asciinema.org/a/210236.svg)](https://asciinema.org/a/210236)

## Integration with shell

Dip can be injected into the current shell (ZSH or Bash).

```sh
eval "$(dip console)"
```

After that we can type commands without `dip` prefix. For example:

```sh
<run-command> *any-args
compose *any-compose-arg
up <service>
down
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

You have two ways.

Install like a typical Ruby gem:

```sh
gem install dip
```

If you don't have installed Ruby, then you could copy a precompiled binary to your system. 
It can be found at [releases page](https://github.com/bibendi/dip/releases)
or type bellow into your terminal:

```sh
curl -L https://github.com/bibendi/dip/releases/download/3.8.3/dip-`uname -s`-`uname -m` > /usr/local/bin/dip
chmod +x /usr/local/bin/dip
``` 

## Docker installation

- [Ubuntu](docs/docker-ubuntu-install.md)
- [Mac OS](docs/docker-for-mac-install.md)

## Usage

```sh
dip --help
dip SUBCOMMAND --help
```

### dip.yml

The configuration file `dip.yml` should be placed in a project root directory.
Also, in some cases, you may want to change the default config path by providing an environment variable `DIP_FILE`.
If nearby places `dip.override.yml` file it would be merged into the main config.

Below is an example of a real config. 
`dip.yml` reference will be written soon. 
Also, you can check out examples in the top.       


```yml
version: '2'

environment:
  COMPOSE_EXT: development

compose:
  files:
    - docker/docker-compose.yml
    - docker/docker-compose.$COMPOSE_EXT.yml
    - docker/docker-compose.$DIP_OS.yml
  project_name: bear

interaction:
  bash:
    service: app
    compose_run_options: [no-deps]

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
    command: bundle exec rails
    subcommands:
      s:
        service: web
        compose_run_options: [service-ports]

  psql:
    service: app
    command: psql -h pg -U postgres

provision:
  - dip compose down --volumes
  - dip compose up -d pg redis
  - dip bash -c ./bin/setup
```

### dip run

Run commands defined within the `interaction` section of dip.yml

```sh
dip run rails c
dip run rake db:migrate
```

`run` argument can be ommited

```sh
dip rake db:migrate
dip VERSION=12352452 rake db:rollback
```

### dip provision

Run commands each by each from `provision` section of dip.yml

### dip compose

Run docker-compose commands that are configured according to the application's dip.yml :

```sh
dip compose COMMAND [OPTIONS]

dip compose up -d redis
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

### dip Nginx

Runs Nginx server container based on [bibendi/nginx-proxy](https://github.com/bibendi/nginx-proxy) image. An application's docker-compose.yml should contain environment variable `VIRTUAL_HOST` and `VIRTUAL_PATH` and connects to external network `frontend`.

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

It runs a DNS server container based on https://github.com/aacebedo/dnsdock. It is used for container to container requests through Nginx. An application's docker-compose.yml should define `DNS` configuration with environment variable `$DIP_DNS` and connect to external network `frontend`. `$DIP_DNS` will be automatically assigned by dip.

```sh
dip dns up

cd foo-project
dip compose exec foo-web curl http://www.bar-app.docker/api/v1/baz_service
```

## Changelog

https://github.com/bibendi/dip/releases
