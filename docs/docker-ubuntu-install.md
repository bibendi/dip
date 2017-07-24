# Ubuntu installation

## Set up docker's engine DNS
Specify dns server and network bridge ip setttings for docker engine, as described [here](https://github.com/aacebedo/dnsdock#setup).

After that you will be sure that dns server of docker's engine is running on 172.17.0.1

```sh
  sudo vim /lib/systemd/system/docker.service
```

```
  # add --bip and --dns settings to this line as follows:
  ExecStart=/usr/bin/dockerd -H fd:// --bip=172.17.0.1/24 --dns=172.17.0.1
```

After that restart docker engine:

```sh
  sudo service docker restart
```

## Make Ubuntu to resolve name with docker's DNS

Disable dnsmasq if you have it:
```
sudo service dnsmasq stop
```

Put docker IP to resolv.conf:
```sh
  echo "nameserver 172.17.0.1" | sudo tee -a /etc/resolvconf/resolv.conf.d/head
```

Check out your docker's dns names are resolved properly:

```sh
  nslookup dnsdock.docker
```

You should have the following output:

```
Server:		172.17.0.1
Address:	172.17.0.1#53

Non-authoritative answer:
Name:	dnsdock.docker
Address: 172.17.0.2
```


# Install dip

go to [releases](https://github.com/bibendi/dip/releases) - and follow instructions for latest release.

That's it. Enjoy!
