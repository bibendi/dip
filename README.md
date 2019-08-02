[![Gem Version](https://badge.fury.io/rb/dip.svg)](https://badge.fury.io/rb/dip)
[![Build Status](https://travis-ci.org/bibendi/dip.svg?branch=master)](https://travis-ci.org/bibendi/dip)
[![Maintainability](https://api.codeclimate.com/v1/badges/d0dca854f0930502f7b3/maintainability)](https://codeclimate.com/github/bibendi/dip/maintainability)

# DIP

Docker Interaction Process

A command-line utility that gives the "native" interaction with applications configured with Docker Compose. It is for local development only. In practice, it creates the feeling that you work without containers.

<p float="left">
<a href="https://evilmartians.com/?utm_source=dip"><img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" height="80" /></a>
<img src="https://ya-webdesign.com/images250_/vertical-divider-png-1.png" width="50" height="100" />
<a href="https://www.jetbrains.com/?from=DIP"><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/JetBrains_Logo_2016.svg/1200px-JetBrains_Logo_2016.svg.png" alt="Sponsored by JetBrains" height="100" /></a></p>

## Presentations and examples

- [Local development with Docker containers](https://slides.com/bibendi/dip)
- Dockerized Ruby on Rails applications: [one](https://github.com/bibendi/dip-example-rails), [two](https://github.com/evilmartians/evil_chat)
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

```shhttps://ya-webdesign.com/images250_/vertical-divider-png-1.pnghttps://ya-webdesign.com/images250_/vertical-divider-png-1.png
VERSION=20180515103400 rails db:migrate:down
```

You could add this `eval` at the end of your `~/.zshrc`, or `~/.bashrc`, or `~/.bash_profile`. 
After that, it will be automatically applied when you open your preferred terminal.

## Installation

You have many ways.

### Homebrew


You can use [Homebrew](https://brew.sh) on macOS (or [Linux](https://docs.brew.sh/Homebrew-on-Linux)).

Today Homebrew tap for DIP is located at https://github.com/bibendi/homebrew-dip

```sh
brew tap bibendi/dip
brew install dip
```

### Ruby Gem

```sh
gem install dip
```

### Precompiled binary

If you don't have installed Ruby, then you could copy a precompiled binary to your system. 
It can be found at [releases page](https://github.com/bibendi/dip/releases)
or type bellow into your terminal:

```sh
curl -L https://github.com/bibendi/dip/releases/download/4.1.0/dip-`uname -s`-`uname -m` > /usr/local/bin/dip
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

### dip generate

If your project has a typical schema, dip can generate all necessary config files with a single command.
Available generators you can find at [here](lib/dip/generators)

```sh
dip generate ruby/gem --ruby 2.6 --bundler 2.0.2 --postgres 11.4

dip generate ruby/rails --ruby 2.6 --bundler 2.0.2 --node 11 --yarn 1.13.0 --postgres 11.4 --redis 4 --webpacker --selenium 
``` 

You can omit any of above options. To list all available generator's options: 

```sh
dip generate [STACK] --help
```

### dip file reference

The configuration file `dip.yml` should be placed in a project root directory.
Also, in some cases, you may want to change the default config path by providing an environment variable `DIP_FILE`.
If nearby places `dip.override.yml` file it would be merged into the main config.

Below is an example of a real config. 
`dip.yml` reference will be written soon. 
Also, you can check out examples in the top.

```yml
# Required minimum dip version
version: '4.1'

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
    description: Open the Bash shell in app's container
    service: app
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
          run_options: [service-ports]

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

`run` argument can be omitted

```sh
dip rake db:migrate
dip VERSION=12352452 rake db:rollback
```

### dip ls

List al available run commands.

```sh
dip ls

bash     # Open the Bash shell in app's container
rails    # Run Rails command
rails s  # Run Rails server at http://localhost:3000
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

### dip nginx

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

Runs a DNS server container based on https://github.com/aacebedo/dnsdock. It is used for container to container requests through Nginx. An application's docker-compose.yml should define `dns` configuration with environment variable `$DIP_DNS` and connect to external network `frontend`. `$DIP_DNS` will be automatically assigned by dip.

```sh
dip dns up

cd foo-project
dip compose exec foo-web curl http://www.bar-app.docker/api/v1/baz_service
```

## Changelog

https://github.com/bibendi/dip/releases
