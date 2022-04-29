
BINARY =ibm-manage-dl-gateway
GOCMD  =go
TEST   ?=$$(go list ./... |grep -v 'vendor')
VERSION =0.1.0
BUILD_TIMESTAMP =$(shell date '+%Y-%m-%d' -d "yesterday")
LDFLAGS ="-X 'main.Version=${VERSION}' -X 'main.BuildTime=$(BUILD_TIMESTAMP)'"

default: clean build test

all: default

test:
	echo $(TEST) | \
		xargs -t ${GOCMD} test -v -timeout=10m

clean:
	${GOCMD} clean
	rm -f ../../bin/win/${BINARY}
	rm -f ../../bin/darwin/${BINARY}
	rm -f ../../bin/linux/${BINARY}

build:
	env GOOS=windows GOARCH=amd64 ${GOCMD} build -ldflags=${LDFLAGS} -o ../../bin/win/${BINARY}
	env GOOS=darwin GOARCH=amd64 ${GOCMD} build -ldflags=${LDFLAGS} -o ../../bin/darwin/${BINARY}
	env GOOS=linux GOARCH=amd64 ${GOCMD} build -ldflags=${LDFLAGS} -o ../../bin/linux/${BINARY}

.PHONY: build clean release
