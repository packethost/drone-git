FROM golang:1.11
ADD . /go/src/github.com/drone-plugins/drone-git
WORKDIR /go/src/github.com/drone-plugins/drone-git
RUN go vet
RUN CGO_ENABLED=0 GO111MODULE=on go build -ldflags "-s -w" -a -tags netgo
RUN lfs_version=2.5.1 && \
    lfs_sha256=9565fa9c2442c3982567a3498c9352cda88e0f6a982648054de0440e273749e7 && \
    mkdir /tmp/${lfs_version} && \
    curl -o /tmp/lfs.tgz -L "https://github.com/git-lfs/git-lfs/releases/download/v${lfs_version}/git-lfs-linux-amd64-v${lfs_version}.tar.gz" \
    && [ "$(sha256sum /tmp/lfs.tgz | awk '{print $1'})" = ${lfs_sha256} ]  && echo "sha256 match on lfs release" || exit 1 \
    && tar xvzf /tmp/lfs.tgz -C /tmp \
    && mv "/tmp/git-lfs" /bin/git-lfs \
    && unset lfs_version lfs_sha256 \
    && rm -r /tmp/${lfs_version}

FROM plugins/base:amd64

LABEL maintainer="Drone.IO Community <drone-dev@googlegroups.com>" \
  org.label-schema.name="Drone Git" \
  org.label-schema.vendor="Drone.IO Community" \
  org.label-schema.schema-version="1.0"

COPY --from=0 /go/src/github.com/drone-plugins/drone-git/drone-git /bin/git-lfs /bin/
RUN apk add --no-cache ca-certificates curl git openssh perl && git lfs install

ENTRYPOINT ["/bin/drone-git"]
