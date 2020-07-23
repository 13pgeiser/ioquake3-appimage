#!/bin/bash
set -e
docker rm -f ioquake3 || true
docker build -t ioquake3 .
docker run --rm --entrypoint cat ioquake3 /ioquake3.tgz > ioquake3.tgz

