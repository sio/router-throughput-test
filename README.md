# Test router throughput capabilities

This repo contains scripts for testing router throughput.

You will need two Linux (preferably Debian) computers to perform this test.
One of them will be connected to WAN port of the tested router, the other one -
to one of LAN ports.

Here is a diagram of test network:

```
                 ┌──────────────┐
                 │    ROUTER    │
                 │ WAN      LAN │
                 └─port────port─┘
                    ▲        ▲
┌─────────────────┐ │        │ ┌─────────────────┐
│   "WAN side"    │ │        │ │    "LAN side"   │
│                 │ │        │ │                 │
│ User-controlled ├─┘        └─┤ User-controlled │
│    computer     │            │    computer     │
└─────────────────┘            └─────────────────┘
```


## Usage

See `make help` for the description of Makefile targets

## Typical test sequence

#### WAN side

Install dependencies while connected to Internet:

```
$ make install-wan
```

Disconnect from Internet, connect fake WAN device to router WAN port.
Then run:

```
$ make static-ip
$ make dhcp-server &
$ make iperf3-server &
```

#### LAN side

This device always stays connected to LAN port of the router, there should be
no physical actions involving this device or its Ethernet cable.

Before replacing WAN connection with our fake ISP device:

```
$ make install-lan
```

After setting up the test network according to the diagram above:

```
$ ifdown eth0; ifup eth0
$ make test
$ less iperf3.log
```
