FROM alpine:3.11

RUN apk add --no-cache git make musl-dev go unzip build-base

# Configure Go
ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV PATH /go/bin:$PATH

RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin

ENV TERRAFORM_VERSION=0.12.24

RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  chmod a+x ./terraform && \
  mv terraform /usr/local/bin
