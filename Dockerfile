FROM alpine:3.11 as builder

WORKDIR /build
ARG BUILD_DIR=/build
ARG ARTIFACT_DIR=/artifacts
RUN mkdir -p ${ARTIFACT_DIR}

# Install aws-iam-authenticator
ARG AWS_IAM_AUTH_SHA256=fe958eff955bea1499015b45dc53392a33f737630efd841cd574559cc0f41800
ARG AWS_IAM_AUTH_VERSION=1.16.8
ADD https://amazon-eks.s3.us-west-2.amazonaws.com/${AWS_IAM_AUTH_VERSION}/2020-04-16/bin/linux/amd64/aws-iam-authenticator ${BUILD_DIR}/aws-iam-authenticator
RUN set -x && \
    echo "${AWS_IAM_AUTH_SHA256}  ${BUILD_DIR}/aws-iam-authenticator" | sha256sum -c - && \
    chmod +x aws-iam-authenticator && \
    mv aws-iam-authenticator ${ARTIFACT_DIR}/

# Install kubectl
ARG KUBECTL_SHA256=bb16739fcad964c197752200ff89d89aad7b118cb1de5725dc53fe924c40e3f7
ARG KUBECTL_VERSION=v1.18.0
ADD https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl ${BUILD_DIR}/kubectl
RUN set -x && \
    echo "${KUBECTL_SHA256}  ${BUILD_DIR}/kubectl" | sha256sum -c - && \
    chmod +x kubectl && \
    mv kubectl ${ARTIFACT_DIR}/

# Install terraform
ARG TERRAFORM_SHA256=602d2529aafdaa0f605c06adb7c72cfb585d8aa19b3f4d8d189b42589e27bf11
ARG TERRAFORM_VERSION=0.12.24
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip ${BUILD_DIR}/terraform.zip
RUN set -x && \
    echo "${TERRAFORM_SHA256}  ${BUILD_DIR}/terraform.zip" | sha256sum -c - && \
    unzip terraform.zip && \
    chmod +x ./terraform && \
    mv terraform ${ARTIFACT_DIR}/



FROM google/cloud-sdk:alpine

RUN apk add --no-cache git make musl-dev go unzip build-base

# Configure Go
ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV PATH /go/bin:$PATH

RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin
COPY --from=builder /artifacts /usr/local/bin
