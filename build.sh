#!/bin/bash

set -eu

export SERVICE=$1
echo "Service: $SERVICE"
export GIT_TAG=$(git name-rev --tags --name-only $(git rev-parse HEAD))
export API_VERSION=$(git name-rev --tags --name-only $(git rev-parse HEAD))
export COMMIT_HASH=$(git rev-parse HEAD)
export COMMIT_HASH_SHORT=$(git rev-parse --short HEAD)
export BUILT_AT=$(LC_ALL=C date -u '+%d %B %Y %r (UTC)')
export ROOT="github.com/${GITHUB_REPOSITORY}"
export IMPORT_VERSION="${ROOT}/internal/${SERVICE}/version"
export LDFLAGS="-w -s -X '${IMPORT_VERSION}.Version=${GIT_TAG}' \
-X '${IMPORT_VERSION}.APIVersion=${API_VERSION}' \
-X '${IMPORT_VERSION}.CommitHash=${COMMIT_HASH}' \
-X '${IMPORT_VERSION}.BuiltAt=${BUILT_AT}'"; \

echo "${LDFLAGS}"

echo "Build"
GOOS=linux GOARCH=amd64 GO111MODULE=on CGO_ENABLED=0 go build -ldflags="${LDFLAGS}" -o ./bin/$SERVICE ./cmd/$SERVICE/main.go &&  echo -n "${COMMIT_HASH_SHORT} (${GIT_TAG})" > ./bin/$SERVICE.commit
GOOS=linux GOARCH=amd64  GO111MODULE=on CGO_ENABLED=0 go build -ldflags="${LDFLAGS}" -o ./bin/$SERVICE-worker ./cmd/worker/main.go && echo -n "${COMMIT_HASH_SHORT} (${GIT_TAG})"> ./bin/$SERVICE-worker.commit
echo "Build $SERVICE service completed!"