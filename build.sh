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


echo "Image geneneration succesfully."
read -p "Do you want to tag and push changes to git [yes/NO]: " choice
choice=${choice:-NO}
choice=${choice,,}

if [ "${choice}" == "yes" ]; then
	echo "> git add Dockerfile dockerhub/* README.md" && \
	git add Dockerfile dockerhub/* README.md && \
	echo '> git commit -m "upgrade to FastRTPS ${TAG_FASTRTPS}"' && \
	git commit -m "upgrade to FastRTPS ${TAG_FASTRTPS}" && \
	echo "> git tag ${TAG_FASTRTPS} -f" && \
	git tag ${TAG_FASTRTPS} -f && \
	echo "> git tag latest -f" && \
	git tag latest -f && \
	echo "> git push" && \
	git push
	echo "> git push --tags -f" && \
	git push --tags -f
fi

