# Binary extract
FROM alpine:3.17.2 as installFile
ARG FRIG_ARCHIVE=IG-7.2.0.zip
ARG FRIG_ARCHIVE_REPOSITORY_URL=

ADD ${FRIG_ARCHIVE_REPOSITORY_URL}${FRIG_ARCHIVE}  /var/tmp/frig.zip

RUN unzip /var/tmp/frig.zip -d /var/tmp/

# Runtime deployment
ARG JRE_IMAGE=darkedges/s2i-forgerock-jvm
ARG JRE_TAG=11.0.18_10-jre-alpine
ARG FORGEROCK_VERSION=7.2.0

FROM darkedges/s2i-forgerock-jvm:11.0.18_10-jre-alpine as base

LABEL io.k8s.description="$DESCRIPTION" \
    io.k8s.display-name="ForgeRock $FORGEROCK_VERSION" \
    io.openshift.expose-services="8080:http" \
    io.openshift.tags="builder,forgerock,forgerock-ig-$FORGEROCK_VERSION" \
    com.redhat.deployments-dir="/opt/app-root/src" \
    com.redhat.dev-mode="DEV_MODE:false" \
    com.redhat.dev-mode.port="DEBUG_PORT:5858" \
    maintainer="Nicholas Irving <nirving@darkedges.com>" \
    summary="$SUMMARY" \
    description="$DESCRIPTION" \
    version="$FORGEROCK_VERSION" \
    name="darkedges/s2i-forgerock-ig" \
    usage="s2i build . darkedges/s2i-forgerock-ig myapp"

COPY --from=0 /var/tmp/identity-gateway /opt/frig/

ENV INSTANCE_DIR /opt/app-root/src

RUN apk add --no-cache tini bash curl jq 

USER 1001

COPY ./s2i/ $STI_SCRIPTS_PATH

EXPOSE 8080

# Set the default CMD to print the usage
CMD ${STI_SCRIPTS_PATH}/usage