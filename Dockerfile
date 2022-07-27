ARG BASE_TAG
FROM teknofile/tkf-docker-base-alpine:${BASE_TAG}

LABEL maintainer="teknofile"

ARG TARGETPLATFORM
ARG ATLANTIS_VERSION
ARG TG_ATLANTIS_CONFIG_VER
ARG TF_VERSION
ARG TG_VERSION

RUN if [ "${TARGETPLATFORM}" == "linux/arm64" ] ; then \
    curl -o /tmp/atlantis.zip -L https://github.com/runatlantis/atlantis/releases/download/v${ATLANTIS_VERSION}/atlantis_linux_arm64.zip ; \
  elif [ "${TARGETPLATFORM}" == "linux/arm/v7" ] ; then \
    curl -o /tmp/atlantis.zip -L https://github.com/runatlantis/atlantis/releases/download/v${ATLANTIS_VERSION}/atlantis_linux_arm.zip ; \
  else \
    curl -o /tmp/atlantis.zip -L https://github.com/runatlantis/atlantis/releases/download/v${ATLANTIS_VERSION}/atlantis_linux_amd64.zip ; \
  fi

# Let's deploy the atlantis bin into /usr/local/bin
RUN unzip /tmp/atlantis.zip -d /usr/local/bin

RUN git clone https://github.com/tfutils/tfenv.git /opt/tfenv && \
  ln -s /opt/tfenv/bin/* /usr/local/bin/ && \
  tfenv install ${TF_VERSION} && \
  tfenv use ${TF_VERSION}

RUN git clone https://github.com/cunymatthieu/tgenv.git /opt/tgenv
RUN ln -s /opt/tgenv/bin/* /usr/local/bin/
RUN tgenv install ${TG_VERSION}
RUN tgenv use ${TG_VERSION}

RUN chown -R abc /opt/tfenv /opt/tgenv

# TODO: This is not cross-platform-aware
RUN curl -sL https://github.com/transcend-io/terragrunt-atlantis-config/releases/download/v${TG_ATLANTIS_CONFIG_VER}/terragrunt-atlantis-config_${TG_ATLANTIS_CONFIG_VER}_linux_amd64.tar.gz -o /tmp/terragrunt-atlantis-config_${TG_ATLANTIS_CONFIG_VER}_linux_amd64.tar.gz
RUN tar xf /tmp/terragrunt-atlantis-config_${TG_ATLANTIS_CONFIG_VER}_linux_amd64.tar.gz -C /
RUN mv /terragrunt-atlantis-config_${TG_ATLANTIS_CONFIG_VER}_linux_amd64/terragrunt-atlantis-config_${TG_ATLANTIS_CONFIG_VER}_linux_amd64 /terragrunt-atlantis-config_${TG_ATLANTIS_CONFIG_VER}_linux_amd64/terragrunt-atlantis-config
RUN install /terragrunt-atlantis-config_${TG_ATLANTIS_CONFIG_VER}_linux_amd64/terragrunt-atlantis-config /usr/local/bin

RUN mkdir -p /config/
# Add local files
COPY root/ /

VOLUME [ "/config" ]
ENTRYPOINT [ "/init" ]