ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Build arguments
ARG BUILD_ARCH
ARG LIVEKIT_VERSION=1.7.2

# Install LiveKit and runtime dependencies
RUN \
    apk add --no-cache \
        ca-certificates \
        tzdata \
        jq \
        curl \
        openssl \
        wget

# Download and install LiveKit server based on architecture
RUN \
    case "${BUILD_ARCH}" in \
        amd64) ARCH="amd64" ;; \
        aarch64) ARCH="arm64" ;; \
        armv7) ARCH="armv7" ;; \
        armhf) ARCH="armv6" ;; \
        i386) ARCH="386" ;; \
        *) echo "Unsupported architecture: ${BUILD_ARCH}" && exit 1 ;; \
    esac \
    && wget -O /tmp/livekit.tar.gz \
        "https://github.com/livekit/livekit/releases/download/v${LIVEKIT_VERSION}/livekit_${LIVEKIT_VERSION}_linux_${ARCH}.tar.gz" \
    && tar -xzf /tmp/livekit.tar.gz -C /tmp \
    && mv /tmp/livekit-server /usr/local/bin/livekit-server \
    && chmod +x /usr/local/bin/livekit-server \
    && rm -f /tmp/livekit.tar.gz

# Create livekit user and directories
RUN \
    addgroup -g 7880 livekit \
    && adduser -D -s /bin/bash -u 7880 -G livekit livekit \
    && mkdir -p /var/lib/livekit \
    && mkdir -p /etc/livekit \
    && mkdir -p /var/log/livekit \
    && mkdir -p /data/livekit

# Set permissions
RUN \
    chown -R livekit:livekit /var/lib/livekit \
    && chown -R livekit:livekit /etc/livekit \
    && chown -R livekit:livekit /var/log/livekit \
    && chown -R livekit:livekit /data/livekit \
    && chmod -R g+w /var/lib/livekit \
    && chmod -R g+w /etc/livekit \
    && chmod -R g+w /var/log/livekit \
    && chmod -R g+w /data/livekit

# Copy rootfs
COPY rootfs /

# Build arguments for labels
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Michal Torma <torma.michal@gmail.com>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Community Add-ons" \
    org.opencontainers.image.authors="Michal Torma <torma.michal@gmail.com>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/MichalTorma/ha-livekit" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

# Expose ports
EXPOSE 7880 7881 50000-50099/udp

# Set working directory
WORKDIR /etc/livekit

# Health check - check if LiveKit is responding on the HTTP port
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:7880/rtc || exit 1
