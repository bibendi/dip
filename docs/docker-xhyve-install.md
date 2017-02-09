# docker-machine-driver-xhyve installation

This document provide information about how to install and configure [docker-machine-driver-xhyve](https://github.com/zchee/docker-machine-driver-xhyve) for use with dip.

## Install VM

```sh
  brew install docker-machine-driver-xhyve

   # docker-machine-driver-xhyve need root owner and uid
  sudo chown root:wheel $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
  sudo chmod u+s $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
```

## Create & start machine

```sh
  docker-machine create --driver xhyve --xhyve-cpu-count=2 --xhyve-memory-size=3000 --xhyve-disk-size=20000 --xhyve-experimental-nfs-share --engine-opt dns=172.17.0.1 work

  echo "$(docker-machine ip work) local.docker" | sudo tee -a /etc/hosts
```

## Configure you environment

```sh
  eval "$(docker-machine env work)"
```

You can also add this to your `.bash_profile`

## Create resolver

Configure OSX so that all .docker requests are forwarded to Docker's DNS server. Since routing has already been taken care of, just create a custom resolver under /etc/resolver/docker with the following content:

```sh
  sudo touch /etc/resolver/docker
  echo "nameserver 172.17.0.1" | sudo tee -a /etc/resolver/docker
```

Then restart OSX's own DNS server:

```sh
  sudo killall -HUP mDNSResponder
```

## Configure routing (after each reboot)

```sh
  sudo route -n add 172.17.0.0/8 local.docker
  DOCKER_INTERFACE=$(route get local.docker | grep interface: | cut -f 2 -d: | tr -d ' ')
  DOCKER_INTERFACE_MEMBERSHIP=$(ifconfig ${DOCKER_INTERFACE} | grep member: | cut -f 2 -d: | cut -c 2-4)
  sudo ifconfig "${DOCKER_INTERFACE}" -hostfilter "${DOCKER_INTERFACE_MEMBERSHIP}"
```

## Check

```sh
  dip dns up
  ping dnsdock.docker
```
