<img src="https://avatars1.githubusercontent.com/u/3853758?v=4&s=100">

# OpenSIPS + HEP Types
This repository provides a proof-of-concept OpenSIPS/RTPEngine/HEP contraption, capable of emitting several advanced OpenSIPS HEP Types to HOMER/HEPIC, not to be used for any production purpose what-so-ever.

<img src="https://i.imgur.com/SLjsWr7.png" />

<!--
### Quick Start
Automated builds of the image are available on [DockerHub](https://hub.docker.com/r/qxip/homer-hepswitch)
```sh
$ docker pull qxip/docker-opensips-hepclient
```
-->

### Custom Build w/ RTPEngine kernel modules
In order for RTPEngine to insert and use its kernel modules on a given system, the container must be built for the specific underlying OS kernel version. Please use the ```dev``` branch to produce a source-compiled build.
```
git clone https://github.com/lmangani/docker-opensips-hepclient
cd docker-opensips-hepclient
docker build -t qxip/docker-opensips-hepclient .
```

### Usage
Use docker-compose to manage the container status
```sh
$ docker-compose up
```
Call relay is enabled on this dev image, so all calls will be forwarded in proxy mode, and HEP logs sent to the configured ```$HOMER_SERVER```
