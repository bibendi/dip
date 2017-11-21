# Docker for Mac

Download and install latest [Docker for Mac](https://www.docker.com/docker-mac).

# d4m-nfs

For the best i/o performance git clone latest [IFSight/d4m-nfs](https://github.com/IFSight/d4m-nfs).

- Remove all shared paths from Docker for Mac Preferences except `/tmp`.
- Run `echo '/Users:/Users:0:0' > ./etc/d4m-nfs-mounts.txt`
- Run `./d4m-nfs.sh` after each reboot.

# Dnsmasq

```sh
  brew install dnsmasq
  echo 'address=/docker/127.0.0.1' >> $(brew --prefix)/etc/dnsmasq.conf
  brew services restart dnsmasq
```

# dip

Install latest [dip](https://github.com/bibendi/dip/releases).

# Example appication

docker-compose.yml

```yml
version: '2'

services:
  app1:
    image: nginx
    environment:
      - VIRTUAL_HOST=*.app1.docker
    networks:
      - default
      - nginx

  app2:
    image: nginx
    environment:
      - VIRTUAL_HOST=*.app2.docker
    networks:
      - default
      - nginx

networks:
  nginx:
    external:
      name: nginx
```

```sh
  dip nginx up

  docker-compose up
  curl www.app1.docker
  curl www.app2.docker
```
