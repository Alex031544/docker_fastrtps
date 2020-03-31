#!/bin/bash

docker build \
	--rm \
	 --no-cache \
	--target publisher \
	-t fastrtps_helloworld_publisher \
	.

docker build \
	--rm \
	--target subscriber \
	-t fastrtps_helloworld_subscriber \
	.
