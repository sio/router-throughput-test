IPERF3?=iperf3
IPERF3_ARGS?=--client $(TARGET) --parallel 2
ifdef IPERF3_PORT
IPERF3_ARGS+=--port $(IPERF3_PORT)
endif


WAN_IFACE?=$(shell ls /sys/class/net|grep -vE 'lo|vir|docker'|head -n1)
WAN_SUBNET?=10.100.10.1/24
WAN_DHCP?=10.100.10.101,10.100.10.199
TARGET?=$(firstword $(subst /, ,$(WAN_SUBNET)))


LOGFILE?=iperf3.log
NO_BUFFER=stdbuf -o0
ifdef LOGFILE
APPEND_TO_LOGFILE=2>&1 | tee --append $(LOGFILE)
endif


.PHONY: test
test: .require-TARGET install-iperf3
test:  # measure up/down througput between this host and $TARGET
	$(NO_BUFFER) $(MAKE) test-bidirectional $(APPEND_TO_LOGFILE)
	$(NO_BUFFER) $(MAKE) test-download $(APPEND_TO_LOGFILE)
	$(NO_BUFFER) $(MAKE) test-upload $(APPEND_TO_LOGFILE)


.PHONY: test-upload
test-upload: .require-TARGET
test-upload: iperf3
test-upload:  # measure throughput from this host to $TARGET


.PHONY: test-download
test-download:  # measure throughput from $TARGET to this host
test-download: test-upload
test-download: IPERF3_ARGS+=--reverse


.PHONY: test-bidirectional
test-bidirectional:  # measure bidirectional throughput (full-duplex test)
test-bidirectional: test-upload
test-bidirectional: IPERF3_ARGS+=--bidir


.PHONY: static-ip
static-ip:  # configure this host to use static IP on first Ethernet interface
	ip addr flush $(WAN_IFACE)
	ip addr replace $(WAN_SUBNET) dev $(WAN_IFACE)
	ip link set $(WAN_IFACE) up
	ip addr show $(WAN_IFACE)
	ip route


.PHONY: dhcp-server
dhcp-server: install-dnsmasq
dhcp-server:  # start DHCP server in a foreground task
	dnsmasq \
		--no-daemon \
		--port=0 \
		--dhcp-range=$(WAN_DHCP) \
		--log-dhcp


.PHONY: iperf3-server
iperf3-server:  # start iperf3 server in a foreground task
iperf3-server: iperf3
iperf3-server: IPERF3_ARGS=--server


.PHONY: install-wan
install-wan:  # prepare WAN-side system
install-wan: install-iperf3 install-dnsmasq


.PHONY: lan
install-lan:  # prepare LAN-side system
install-lan: install-iperf3


.PHONY: install-iperf3
install-iperf3:  # install iperf3 on Debian based systems
ifeq (,$(shell command -v $(IPERF3) 2>/dev/null))
	apt -y install iperf3
endif


.PHONY: install-dnsmasq
install-dnsmasq:  # install dnsmasq on Debian based systems
ifeq (,$(shell command -v dnsmasq 2>/dev/null))
	apt -y install dnsmasq
endif


.PHONY: iperf3
iperf3: install-iperf3
iperf3:  # execute iperf3 with $IPERF3_ARGS
	$(IPERF3) $(IPERF3_ARGS)


define HELP_HEADER
Test router throughput capabilities

This Makefile provides the following targets:
endef
.DEFAULT_GOAL=help
.PHONY: help
help: export HELP_HEADER?=
help: MAKEFILE=$(lastword $(MAKEFILE_LIST))
help:  # show this help message and exit
	@echo "$$HELP_HEADER"
	@awk '/^[^ \t]+:  # / {sub(":  #", "\t"); print "    " $$0}' $(MAKEFILE)|column -t -s '	'


.PHONY: .require-TARGET
.require-TARGET:
ifndef TARGET
	$(error Required variable is not defined: TARGET)
endif
