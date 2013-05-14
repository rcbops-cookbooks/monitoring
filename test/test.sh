#!/bin/bash

thor foodcritic:lint -f any || exit 1
thor tailor:lint || exit 1
kitchen test "default-vagrant-*"
