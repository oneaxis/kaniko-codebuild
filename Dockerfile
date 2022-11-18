FROM gcr.io/kaniko-project/executor:debug AS kaniko

FROM amazon/aws-cli

# Add kaniko to this image by re-using binaries and steps from official image
COPY --from=kaniko /kaniko/ /kaniko/
COPY --from=kaniko /kaniko/warmer /kaniko/warmer
COPY --from=kaniko /kaniko/docker-credential-* /kaniko/
COPY --from=kaniko /kaniko/.docker /kaniko/.docker

# Install addon libraries
RUN yum install -y \
    unzip \
    zip \
    jq \
    curl

ENV PATH $PATH:/usr/local/bin:/kaniko
ENV DOCKER_CONFIG /kaniko/.docker/
ENV DOCKER_CREDENTIAL_GCR_CONFIG /kaniko/.config/gcloud/docker_credential_gcr_config.json

# Fix symlink issue
# RUN rm /var/spool/mail
# RUN mkdir /var/spool/mail

ENTRYPOINT [ "/bin/bash" ]