# docker-machine-driver-xhyve installation

This document provide information about how to install and configure [docker-machine-driver-xhyve](https://github.com/zchee/docker-machine-driver-xhyve) for use with dip.

1. Install VM

 ```
 $ brew install docker-machine-driver-xhyve

 # docker-machine-driver-xhyve need root owner and uid
 $ sudo chown root:wheel $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
 $ sudo chmod u+s $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
 ```

2. Create & start machine

 ```
 $ docker-machine create --driver xhyve --xhyve-cpu-count=2 --xhyve-memory-size=2048 --xhyve-disk-size=20000 --xhyve-experimental-nfs-share dip-docker
 ```

3. Configure you environment

 ```
 $ eval "$(docker-machine env dip-docker)"
 ```
 You can also add this to your `.bash_profile`

4. Configure routing

 ```
 $ sudo route -n add 172.16.0.0/12 ${docker-machine ip dip-docker}
 $ ifconfig | grep -B 3 192.168.64 | head -n 1
 bridge100: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
 $ ifconfig bridge100 | grep member: | cut -f 2 -d: | cut -c 2-4
 en7
 $ sudo ifconfig bridge100 -hostfilter en7
 ```

5. Configure docker daemon

 ```
 $ docker-machine ssh dip-docker
 $  sudo vi /var/lib/boot2docker/profile

 # add "--dns 172.17.0.1" and "--bip 172.17.0.1" to EXTRA_ARGS

 $ sudo /etc/init.d/docker restart
 ```

6. start `dip dns up` and put dns ip - `172.17.0.1` in `System Settings -> Network -> Advanced`

7. Have fun! `dnsdock` and other stuff should work by now.
