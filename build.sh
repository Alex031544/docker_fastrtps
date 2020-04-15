#/bin/bash

TAG_FASTRTPS='v1.10.0'

docker build \
	--rm \
	--target dev \
	-t fastrtps:${TAG_FASTRTPS}-dev \
	-f Dockerfile \
	.

docker build \
	--rm \
	--target runtime \
	-t fastrtps:${TAG_FASTRTPS} \
	-f Dockerfile \
	.

docker build \
	--rm \
	--target example \
	-t fastrtps:${TAG_FASTRTPS}-example \
	-f Dockerfile \
	.

