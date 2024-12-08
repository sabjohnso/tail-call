SHELL  = /bin/bash

srcdir = $(shell pwd)

TARGETS = tail-call.elc

LOCAL_PATHS = -L $PWD -L $PWD/tests
COMPILE_FLAGS = -f batch-byte-compile
TEST_FLAGS = -f ert-run-tests-batch-and-exit


all: $(TARGETS)

.PHONY: test clean

tail-call.elc: tail-call.el
	emacs -batch $(COMPILE_FLAGS) $<

tests/test-tail-call.elc: tail-call.elc tests/test-tail-call.el
	emacs -batch $(DEPS) -L ${PWD} -l tail-call $(COMPILE_FLAGS) tests/test-tail-call.el

test: tail-call.elc tests/test-tail-call.elc
	emacs -batch -L ${PWD} -l tail-call -L ${PWD}/tests -l test-tail-call $(TEST_FLAGS)

clean:
	rm -rf ${srcdir}/*.elc
	rm -rf ${srcdir}/test/*.elc
