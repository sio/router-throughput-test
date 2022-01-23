IPERF3?=iperf3
IPERF3_ARGS?=--client $(TARGET) --parallel 2


.PHONY: wan
wan:  # prepare WAN-side system


.PHONY: lan
lan:  # prepare LAN-side system


.PHONY: test
test: install-iperf3
test: .require-TARGET
test:  # measure throughput from $TARGET to this host
	$(IPERF3) $(IPERF3_ARGS)


.PHONY: test-reverse
test-reverse:  # measure throughput from this host to $TARGET
test-reverse: test
test-reverse: IPERF3_ARGS+=--reverse


.PHONY: dhcp-server
dhcp-server: install-dnsmasq
dhcp-server:  # start DHCP server in a foreground task


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
	@awk '/^\S+:  # / {sub(":  #", "\t"); print "    " $$0}' $(MAKEFILE)|column -t -s '	'


.PHONY: .require-TARGET
.require-TARGET:
ifndef TARGET
	$(error Required variable is not defined: TARGET)
endif
