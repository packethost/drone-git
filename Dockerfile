FROM golang:1.14
ADD . /go/src/github.com/drone-plugins/drone-git
WORKDIR /go/src/github.com/drone-plugins/drone-git
RUN go vet
RUN CGO_ENABLED=0 go build -ldflags "-s -w" -a -tags netgo
RUN lfs_version=2.11.0 && \
    lfs_sha256=46508eb932c2ec0003a940f179246708d4ddc2fec439dcacbf20ff9e98b957c9 && \
    mkdir /tmp/${lfs_version} && \
    curl -o /tmp/lfs.tgz -L "https://github.com/git-lfs/git-lfs/releases/download/v${lfs_version}/git-lfs-linux-amd64-v${lfs_version}.tar.gz" \
    && [ "$(sha256sum /tmp/lfs.tgz | awk '{print $1'})" = ${lfs_sha256} ]  && echo "sha256 match on lfs release" || exit 1 \
    && tar xvzf /tmp/lfs.tgz -C /tmp \
    && mv "/tmp/git-lfs" /bin/git-lfs \
    && unset lfs_version lfs_sha256 \
    && rm -r /tmp/${lfs_version}

FROM alpine:3.12@sha256:a15790640a6690aa1730c38cf0a440e2aa44aaca9b0e8931a9f2b0d7cc90fd65
RUN apk add --no-cache ca-certificates mailcap

COPY --from=0 /go/src/github.com/drone-plugins/drone-git/drone-git /bin/git-lfs /bin/
RUN apk add --no-cache ca-certificates curl git openssh perl && git lfs install
RUN git config --system user.name "Drone" && git config --system user.email "drone@drone"

ENTRYPOINT ["/bin/drone-git"]
