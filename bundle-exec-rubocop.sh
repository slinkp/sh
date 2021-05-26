#!/bin/bash

which bundle >/dev/null
if [ $? -eq 0 ]; then
    # TODO this fails if we fall back to global `bundle` and there's no Gemfile locally.
    # eg when just editing a little ruby script in some random place.
    # Is there not a better way to degrade?
	bundle exec rubocop $@
    exit $?
fi
which rubocop >/dev/null
if [ $? -eq 0 ]; then
	rubocop $@
    exit $?
else
    exit 1
fi
