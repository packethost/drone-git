FROM golang:1.10
ADD . /go/src/github.com/drone-plugins/drone-git
WORKDIR /go/src/github.com/drone-plugins/drone-git
RUN go vet
RUN CGO_ENABLED=0 go build -ldflags "-s -w -X main.build=$DRONE_BUILD_NUMBER" -a -tags netgo

FROM plugins/base:amd64
MAINTAINER Drone.IO Community <drone-dev@googlegroups.com>

LABEL org.label-schema.version=latest
LABEL org.label-schema.vcs-url="https://github.com/drone-plugins/drone-git.git"
LABEL org.label-schema.name="Drone Git"
LABEL org.label-schema.vendor="Drone.IO Community"
LABEL org.label-schema.schema-version="1.0"

RUN apk add --no-cache ca-certificates git openssh curl perl

COPY --from=0 /go/src/github.com/drone-plugins/drone-git/drone-git /bin
ENTRYPOINT ["/bin/drone-git"]
