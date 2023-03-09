#! /bin/bash

#/sroperator
#dlv --listen=:2345 --headless=true --api-version=2 --accept-multiclient exec ./sroperator
while :; do sleep 10; done
#pgrep -f sroperator | xargs dlv --headless -l 0.0.0.0:2345 --api-version 2 --accept-multiclient attach

