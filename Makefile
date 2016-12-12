.PHONY: doc
ALL_SWIM := $(shell echo doc/guide/*.swim)
ALL_GUIDE := $(ALL_SWIM:doc/guide/%.swim=guide/%.pod) guide/ReadMe.pod

default: help

help:
	@echo 'all - doc guide'
	@echo 'doc - Generate the docs'
	@echo 'guide - Generate guide/ files from doc/guide/ files'
	@echo 'help   - Show help'

all: doc guide

doc: ReadMe.pod

ReadMe.pod: doc/yaml-dev-kit.swim
	swim --to=pod --meta=guide/Meta --complete --wrap < $< > $@

guide: $(ALL_GUIDE)

guide/%.pod: doc/guide/%.swim
	@[ -d guide ] || { \
	    git clone $$(git config remote.origin.url) -b guide guide; \
	    sleep 1; \
	    touch doc/guide/*.swim; \
	}
	swim --to=pod --meta=guide/Meta --complete --wrap < $< > $@

guide/ReadMe.pod: doc/guide/index.swim
	swim --to=pod --meta=guide/Meta --complete --wrap < $< > $@

guide-status:
	@(cd guide; git add -Af .; git status --short)

guide-diff:
	@(cd guide; git add -Af .; git diff --cached)

guide-push:
	@[ -z "$$(cd guide; git status --short)" ] || { \
	    cd guide; \
	    git add -Af .; \
	    git commit -m 'Regenerated guide files'; \
	    git push --force origin guide; \
	}

clean:
	rm -fr guide
