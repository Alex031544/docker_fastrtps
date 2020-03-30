#!/bin/bash

# create a directory for the generated code
mkdir -p gen

docker run \
	--rm \
	-it \
	--user $(id -u ${USER}):$(id -g ${USER}) \
	--volume ${PWD}/idl:/opt/idl \
	--volume ${PWD}/gen:/opt/gen \
	alex031544/fastrtps:latest-dev \
	fastrtpsgen \
		-d /opt/gen \
		-example CMake \
		/opt/idl/MyDataStructure.idl
