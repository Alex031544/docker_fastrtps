#/bin/bash

TAG_FASTRTPS='v1.9.4'

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

docker build \
	--rm \
	--build-arg TAG_FASTRTPS=${TAG_FASTRTPS} \
	-t fastrtps:${TAG_FASTRTPS}-idl-demo \
	-f Dockerfile.idl-demo \
	.
