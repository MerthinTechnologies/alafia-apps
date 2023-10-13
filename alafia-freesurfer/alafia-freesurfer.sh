#!/bin/bash
export FS_LICENSE=/alafia-freesurfer.license
docker run \
	--interactive \
	--tty \
	--rm \
	--platform=amd64 \
	--volume=/opt/alafia-ai/alafia-freesurfer/alafia-freesurfer.license:/alafia-freesurfer.license \
	--hostname="freesurfer-7.4.1" \
	freesurfer/freesurfer:7.4.1
