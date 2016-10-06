# DIP

Docker Interaction Process

CLI utility for straightforward provisioning and interacting with application configured by docker-compose.

DIP also contains commands for running support containers such as ssh agent and dns server.

## Installation

```sh
curl -L https://github.com/bibendi/dip/releases/download/0.1.0/dip-`uname -s`-`uname -m` > /usr/local/bin/dip
chmod +x /usr/local/bin/dip
```

## Usage

```sh
dip --help
dip SUBCOMMAND --help
```

### dip compose

Run docker-compose commands that is configured according with application dip.yml

```sh
dip compose COMMAND [OPTIONS]
```

### dip ssh

Runs ssh agent container base on https://github.com/whilp/ssh-agent with your ~/.ssh/id_rsa.
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

## dip dns

Runs DNS server container based on https://github.com/aacebedo/dnsdock

```sh
dip dns up
```

### Installation

#### Ubuntu

TODO

#### Mac OS X

First, let's start by configuring the default Docker service DNS server to IP where the DNS server will run (`172.17.0.1`). Currently, this requires SSH'ing into the VM and editing `/etc/default/docker`

```sh
ssh docker@local.docker

vi /etc/default/docker
# Add the DNS server static IP via `--bip` and `--dns`
# Change DOCKER_ARGS to:
DOCKER_ARGS="-H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375 -s btrfs --bip=172.17.0.1/24 --dns=172.17.0.1"
# save :x

exit

dlite stop && dlite start
```

Lastly, configure OSX so that all `.docker` requests are forwarded to Docker's DNS server. Since routing has already been taken care of, just create a custom resolver under `/etc/resolver/docker` with the following content:

```
nameserver 172.17.0.1
```

Then restart OSX's own DNS server:

```sh
sudo killall -HUP mDNSResponder
```

By default, Docker creates a virtual interface named `docker0` on the host machine that forwards packets between any other network interface.

However, on OSX, this means you are not able to access the Docker network directly. To be able to do so, you need add a route and allow traffic from any host on the interface that connects to the VM.

Run the following commands on your OSX machine:

```sh
sudo route -n add 172.17.0.0/8 local.docker
DOCKER_INTERFACE=$(route get local.docker | grep interface: | cut -f 2 -d: | tr -d ' ')
DOCKER_INTERFACE_MEMBERSHIP=$(ifconfig ${DOCKER_INTERFACE} | grep member: | cut -f 2 -d: | cut -c 2-4)
sudo ifconfig "${DOCKER_INTERFACE}" -hostfilter "${DOCKER_INTERFACE_MEMBERSHIP}"
```

Check:

```sh
ping dnsdock.docker
```

# Docker

## Installation

### Ubuntu

TODO

### Mac OS X

```
sudo brew install docker
sudo brew switch docker 1.12.1
```

#### dlite

Download https://github.com/nlf/dlite/releases/download/1.1.5/dlite

```sh
sudo dlite install -c 2 -m 4 -d 20 -S $HOME
```

##### Simple

- `dlite stop`
- download `bzImage` and `rootfs.cpio.xz` https://github.com/bibendi/dhyve-os/releases/tag/2.3.1
- move in `~/.dlite/`
- `dlite start`

##### or Advanced (for other docker version)

```sh
git clone https://github.com/nlf/dhyve-os.git
cd dhyve-os
git checkout legacy
vi Dockerfile
# find the DOCKER_VERSION and replace with needed version
make
dlite stop
cp output/{bzImage,rootfs.cpio.xz} ~/.dlite/
dlite start
```
