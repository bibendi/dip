# Docker

https://docs.docker.com/install/linux/docker-ce/ubuntu/

# Docker Compose

https://docs.docker.com/compose/install/

# Dnsmasq

**WARNING**: Latest Ubuntu 18.04 already runs own local dns resolver at *.localhost. Dnsmasq is not needed. In that case you should run `dip dns` and `dip nginx` with option `--domain localhost`.

```sh
sudo apt-get install dnsmasq
echo "address=/docker/127.0.0.1" | sudo tee -a /etc/dnsmasq.conf
sudo service dnsmasq restart
```
