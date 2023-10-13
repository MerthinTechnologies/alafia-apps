#!/bin/bash
docker run \
	--interactive \
	--tty \
	--rm \
	--platform=amd64 \
	--hostname="fsl-6.0.4" \
	fsldevelopment/fsl-linux-64
	#brainlife/fsl:6.0.4-patched2
	#gcr.io/ris-registry-shared/fsl6:latest

