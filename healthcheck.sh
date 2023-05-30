#!/bin/sh

TARGET="ip.me"
CURL_OPTS="-s"

curl ${CURL_OPTS} "https://${TARGET}" || exit 1
