ARG BASE_TAG
FROM teknofile/tkf-docker-base-alpine:${BASE_TAG}

LABEL maintainer="teknofile"

ARG TARGETPLATFORM
ARG ATLANTIS_VERSION

RUN if [ "${TARGETPLATFORM}" == "linux/arm64" ] ; then \
    curl -o /tmp/atlantis.zip -L https://github.com/runatlantis/atlantis/releases/download/v${ARG ATLANTIS_VERSION}/atlantis_linux_arm64.zip ; \
  elif [ "${TARGETPLATFORM}" == "linux/arm/v7" ] ; then \
    curl -o /tmp/atlantis.zip -L https://github.com/runatlantis/atlantis/releases/download/v${ARG ATLANTIS_VERSION}/atlantis_linux_arm.zip ; \
  else \
    curl -o /tmp/atlantis.zip -L https://github.com/runatlantis/atlantis/releases/download/v${ARG ATLANTIS_VERSION}/atlantis_linux_amd64.zip ; \
  fi

# Let's deploy the atlantis bin into /usr/local/bin
RUN unzip /tmp/atlantis.zip -d /usr/local/bin

RUN mkdir -p /config/
# Add local files
COPY root/ /

VOLUME [ "/config" ]
ENTRYPOINT [ "/init" ]