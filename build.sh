#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

IMAGE_VERSION="16.04-1.23.4"
IMAGE_NAME="turtletramp/golang-ubuntu"
IMAGE_TAG="${IMAGE_NAME}:${IMAGE_VERSION}"
GOLANG_VERSION="1.23.4"

GOLANG_ARCHIVE="go${GOLANG_VERSION}.linux-amd64.tar.gz"
GOLANG_ARCHIVE_SHA256="6924efde5de86fe277676e929dc9917d466efa02fb934197bc2eba35d5680971"
GOLANG_DOWNLOAD_URL=https://go.dev/dl/${GOLANG_ARCHIVE}

usage()
{
	echo "usage: $0 [--tag]                  Create image ${IMAGE_NAME}"
	echo "       $0 [-h | --help ]           Display usage information"
	echo
	echo " Options:"
	echo "	-p | --push		Tag and push image to the internal registry"
}

while [ "$#" -ne 0 ]; do
	case "$1" in
	"-h" | "--help")
		usage && exit 1;;
	"-p" | "--push")
		CMD_PUSH="1";;
	*)
		break;;
	esac
	shift 1
done

if [ ! -f ${DIR}/${GOLANG_ARCHIVE} ]; then
    wget -O ${DIR}/${GOLANG_ARCHIVE} ${GOLANG_DOWNLOAD_URL}
fi
# Validate SHA256 sum
echo "${GOLANG_ARCHIVE_SHA256}  ${DIR}/${GOLANG_ARCHIVE}" | sha256sum -c -
if [ $? -ne 0 ]; then
    echo "SHA256 checksum validation failed - deleting local file - try again!"
    rm -f ${DIR}/${GOLANG_ARCHIVE}
    exit 1
fi

docker build --build-arg GOLANG_ARCHIVE=${GOLANG_ARCHIVE} -t ${IMAGE_TAG} .
if [ "$CMD_PUSH" == "1" ]; then
	docker push ${IMAGE_TAG}
fi

