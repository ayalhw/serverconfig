#!/usr/bin/env bash

git submodule foreach rm -f .git/index.lock
git submodule sync
git submodule update --init --recursive
