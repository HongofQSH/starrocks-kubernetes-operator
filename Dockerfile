# Build the operator binary
FROM golang:bullseye as builder
RUN echo "nameserver 114.80.23.201" >> /etc/resolv.conf

#WORKDIR /workspace
WORKDIR /
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn,direct
ENV http_proxy "http://192.168.130.250:8080"
ENV https_proxy "http://192.168.130.250:8080"
RUN apt update
RUN apt -y install net-tools
#RUN apt -y install iputils-ping
ENV http_proxy ""
ENV https_proxy ""
RUN go mod download

# Copy the go source
COPY cmd/ cmd/
COPY common/ common/
COPY pkg/ pkg/

# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -gcflags="all=-N -l" -o sroperator cmd/main.go


COPY dlv /usr/local/bin 
COPY start.sh start.sh
RUN chmod +x ./start.sh



