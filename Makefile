.PHONY: wan
wan:  # prepare WAN-side system


.PHONY: lan
lan:  # prepare LAN-side system


.PHONY: test
test:  # measure throughput from $TARGET to this host


.PHONY: test-reverse
test-reverse:  # measure throughput from this host to $TARGET
test-reverse: test
test-reverse: IPERF3_ARGS+=--reverse


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
