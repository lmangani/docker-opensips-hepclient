<img src="https://avatars1.githubusercontent.com/u/3853758?v=4&s=100">

# OpenSIPS 3.1 + [SIP|REST|XLOG|MI] Types
This repository provides a proof-of-concept OpenSIPS/RTPEngine/HEP contraption, capable of emitting several advanced **OpenSIPS HEP** Types to **HOMER**/**HEPIC**, not to be used for any production purpose what-so-ever.

This container will act as a pass-through proxy and allow any destination such as your existing SIP PBX.


### Quick Start
Automated builds of the image are available on [DockerHub](https://hub.docker.com/r/qxip/homer-hepswitch)
```sh
$ docker pull qxip/docker-opensips-hepclient
```

### Usage
Build or pull the image, and customize the settings, and use docker-compose to manage the container:
```yaml
version: '2'
services:
  opensips-hepclient:
    image: qxip/docker-opensips-hepclient
    privileged: true
    restart: always
    environment:
      ADVERTISED_RANGE_FIRST: 20000
      ADVERTISED_RANGE_LAST: 20100
      HOMER_SERVER: '172.16.90.60'
      HOMER_PORT: 9060
    volumes:
       - /var/lib/mysql
    ports:
      - "5060:5060/udp"
      - "5061:5061/tcp"
      - "20000-20100:20000-20100/udp"
```
```sh
$ docker-compose up
```

_NB: Call relay is enabled on this dev image, so all calls will be forwarded in proxy mode, and HEP logs sent to the configured ```$HOMER_SERVER```_


### Optional: Custom Build w/ RTPEngine kernel modules
In order for RTPEngine to insert and use its kernel modules on a given system, the container must be built for the specific underlying OS kernel version. Please use the ```dev``` branch to produce a source-compiled build.
```
git clone https://github.com/lmangani/docker-opensips-hepclient
cd docker-opensips-hepclient
docker build -t qxip/docker-opensips-hepclient .
```

------------

## HEP Configuration
The following key configuration elements control the new HEP features

### Tracing modules
```
loadmodule "proto_hep.so"
modparam("proto_hep", "hep_id", "[hid]127.0.0.1:9060;transport=udp;version=3")
modparam("proto_hep", "homer5_on", 0)  # do JSON encapsulation

loadmodule "siptrace.so"
modparam("siptrace", "trace_id", "[tid]uri=hep:hid")
```

### HEP Route
```
route[to_homer] {
	xlog("SCRIPT:DBG: sending message out to Homer\n");
	# see declaration of tid in trace_id section
	$var(trace_id) = "tid";
	$var(trace_type) = NULL;

	if (!has_totag()) {
		if (is_method("INVITE"))
			$var(trace_type) = "dialog";
		else if (!is_method("CANCEL"))
			$var(trace_type) = "transaction";
	} else if (is_method("SUBSCRIBE|NOTIFY")) {
		$var(trace_type) = "transaction";
	} else {
		$var(trace_type) = NULL;
	}

	# do trace here
	switch ($var(trace_type)) {
	case "dialog":
		sip_trace("$var(trace_id)", "d", "sip|xlog|rest");
		break;
	case "transaction":
		sip_trace("$var(trace_id)", "t", "sip|xlog");
		break;
	case "message":
		sip_trace("$var(trace_id)", "m", "sip|xlog");
		break;
	}
}
```
