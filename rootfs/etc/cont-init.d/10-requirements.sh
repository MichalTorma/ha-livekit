#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: LiveKit Server
# Check requirements and basic setup
# ==============================================================================

bashio::log.info "Checking LiveKit requirements..."

# Check if API key and secret are provided
if ! bashio::config.has_value 'api_key' || ! bashio::config.has_value 'api_secret'; then
    bashio::log.fatal
    bashio::log.fatal "Both 'api_key' and 'api_secret' must be configured!"
    bashio::log.fatal "Please configure these in the add-on configuration."
    bashio::log.fatal
    bashio::exit.nok
fi

API_KEY=$(bashio::config 'api_key')
API_SECRET=$(bashio::config 'api_secret')

# Validate API key format (should be alphanumeric)
if [[ ! "${API_KEY}" =~ ^[a-zA-Z0-9]+$ ]]; then
    bashio::log.warning "API key should contain only alphanumeric characters"
fi

# Check API secret length (should be at least 32 characters for security)
if [[ ${#API_SECRET} -lt 32 ]]; then
    bashio::log.warning "API secret should be at least 32 characters long for security"
fi

# Check if SSL is configured properly
USE_SSL=$(bashio::config 'use_ssl')
if bashio::var.true "${USE_SSL}"; then
    CERT_FILE=$(bashio::config 'cert_file')
    PKEY_FILE=$(bashio::config 'pkey_file')
    
    if bashio::var.has_value "${CERT_FILE}" && bashio::var.has_value "${PKEY_FILE}"; then
        if bashio::fs.file_exists "/ssl/${CERT_FILE}" && bashio::fs.file_exists "/ssl/${PKEY_FILE}"; then
            bashio::log.info "SSL certificates found and will be used"
        else
            bashio::log.warning "SSL enabled but certificate files not found in /ssl/"
            bashio::log.warning "Certificate: /ssl/${CERT_FILE}"
            bashio::log.warning "Private key: /ssl/${PKEY_FILE}"
        fi
    else
        bashio::log.warning "SSL enabled but certificate files not specified"
    fi
fi

# Check port configuration
HTTP_PORT=$(bashio::config 'http_port')
RTC_TCP_PORT=$(bashio::config 'rtc_tcp_port')
UDP_MIN=$(bashio::config 'rtc_udp_port_min')
UDP_MAX=$(bashio::config 'rtc_udp_port_max')

if [[ ${UDP_MIN} -ge ${UDP_MAX} ]]; then
    bashio::log.fatal "UDP port minimum (${UDP_MIN}) must be less than maximum (${UDP_MAX})"
    bashio::exit.nok
fi

# Warn about potential port conflicts
if [[ ${HTTP_PORT} -eq 3478 ]] || [[ ${RTC_TCP_PORT} -eq 3478 ]]; then
    bashio::log.warning "Port 3478 is typically used by Coturn STUN/TURN server"
    bashio::log.warning "Make sure there are no port conflicts if running both add-ons"
fi

bashio::log.info "Requirements check completed successfully"
