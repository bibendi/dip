# Docker for Mac

Download and install [Docker for Mac](https://www.docker.com/docker-mac).

**WARNING**: Latest Docker for Mac 17.12.0-ce-mac46 seems to [break d4m-nfs](https://github.com/IFSight/d4m-nfs/issues/55).

# d4m-nfs

For the best i/o performance git clone latest [IFSight/d4m-nfs](https://github.com/IFSight/d4m-nfs).

- Remove all shared paths from Docker for Mac Preferences except `/tmp`.
- Run `echo '/Users:/Users:0:0' > ./etc/d4m-nfs-mounts.txt`
- Run `./d4m-nfs.sh` after each reboot.

# Create resolver

```sh
  sudo touch /etc/resolver/docker
  echo "nameserver 127.0.0.1" | sudo tee -a /etc/resolver/docker
```

# Dnsmasq

```sh
  brew install dnsmasq
  echo 'address=/docker/127.0.0.1' >> $(brew --prefix)/etc/dnsmasq.conf
  brew services restart dnsmasq
```

# dip

Install latest [dip](https://github.com/bibendi/dip/releases).
