#/bin/bash

TAG_FASTRTPS='v2.0.0'

task () {
	echo ""
	echo "#############################################"
	echo "   $1"
	echo "#############################################"
	echo ""
}


task "Build target: fastrtps:${TAG_FASTRTPS}-dev"

docker build \
	--rm \
	--target dev \
	-t fastrtps:${TAG_FASTRTPS}-dev \
	-f Dockerfile \
	.

if [ "$?" -ne 0 ];then
	>&2 echo "Build of target failed: fastrtps:${TAG_FASTRTPS}-dev"
	exit 1
fi


task "Build target: fastrtps:${TAG_FASTRTPS}"

docker build \
	--rm \
	--target runtime \
	-t fastrtps:${TAG_FASTRTPS} \
	-f Dockerfile \
	.

if [ "$?" -ne 0 ];then
	>&2 echo "Build of target failed: fastrtps:${TAG_FASTRTPS}"
	exit 2
fi


task "Build target: fastrtps:${TAG_FASTRTPS}-example"

docker build \
	--rm \
	--target example \
	-t fastrtps:${TAG_FASTRTPS}-example \
	-f Dockerfile \
	.

if [ "$?" -ne 0 ];then
	>&2 echo "Build of target failed: fastrtps:${TAG_FASTRTPS}-example"
	exit 3
fi


task "generate Dockerfiles for docker hub"

python3 gen_dockerfiles_for_docker_hub.py

if [ "$?" -ne 0 ];then
	>&2 echo "Failed to generate Dockerfiles for docker hub"
	exit 4
fi

