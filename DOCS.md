# Home Assistant Add-on: LiveKit Server

A LiveKit server for real-time video, audio, and data communication with Matrix/Synapse integration.

## Installation

1. Navigate to **Settings** → **Add-ons** → **Add-on Store** in your Home Assistant frontend.
2. Add this repository if not already added.
3. Install the "LiveKit Server" add-on.
4. Configure the add-on (see configuration options below).
5. Start the add-on.

## Configuration

Add-on configuration:

```yaml
# Server Configuration
domain: "homeassistant.local"
http_port: 7880
rtc_tcp_port: 7881
rtc_udp_port_min: 50000
rtc_udp_port_max: 50099

# Authentication & Security (REQUIRED)
api_key: "your-api-key"
api_secret: "your-very-long-random-secret"

# SSL/TLS Configuration
use_ssl: false
cert_file: "fullchain.pem"
pkey_file: "privkey.pem"

# TURN Server Configuration
turn_enabled: true
turn_servers:
  - "turn:homeassistant.local:3478"
turn_username: ""
turn_password: ""
turn_static_auth_secret: ""

# Matrix Integration
matrix_homeserver_url: ""
matrix_widget_url: ""

# Logging
log_level: "info"
verbose: false

# Advanced Settings
external_ip: ""
use_ice_lite: false
webhook_urls: []
```

### Configuration Options

#### Server Configuration

- **domain**: The domain where LiveKit will be accessible (default: `homeassistant.local`)
- **http_port**: HTTP API and WebRTC port (default: `7880`)
- **rtc_tcp_port**: RTC TCP port (default: `7881`)
- **rtc_udp_port_min/max**: UDP port range for direct WebRTC media streams (default: `40000-40099`)
  - **Important**: This range should NOT overlap with your TURN server's media relay ports
  - If using Coturn addon, it uses 49152-65535, so LiveKit uses 40000-40099 to avoid conflicts

**Important**: Make sure these ports don't conflict with other services, especially if you're running the Coturn add-on.

#### Authentication & Security (Required)

**api_key**: A unique identifier for your LiveKit server
- Use alphanumeric characters only
- Example: `"mylivekitserver"`

**api_secret**: A secret key for JWT token generation
- **Must be at least 32 characters long for security**
- Use a randomly generated string
- Example: `"abcd1234567890abcd1234567890abcd"`

Generate a secure secret:
```bash
openssl rand -hex 32
```

#### SSL/TLS Configuration

For secure connections (recommended for production):

```yaml
use_ssl: true
cert_file: "fullchain.pem"
pkey_file: "privkey.pem"
```

Place your SSL certificate files in the `/ssl/` Home Assistant directory. The files should be:
- **cert_file**: Your SSL certificate (usually `fullchain.pem` from Let's Encrypt)
- **pkey_file**: Your private key (usually `privkey.pem` from Let's Encrypt)

#### TURN Server Configuration

For NAT traversal and firewall bypass (recommended for production):

**Method 1: Using Coturn Add-on (Recommended)**
```yaml
turn_enabled: true
turn_servers:
  - "turn:your-domain.com:3478"
  - "turns:your-domain.com:5349"  # TLS version
turn_static_auth_secret: "your-coturn-static-secret"
```

**Method 2: Using TURN Username/Password**
```yaml
turn_enabled: true
turn_servers:
  - "turn:your-turn-server.com:3478"
turn_username: "your-turn-username"
turn_password: "your-turn-password"
```

#### Matrix Integration

For Matrix/Synapse group calls integration:

```yaml
matrix_homeserver_url: "https://matrix.your-domain.com"
matrix_widget_url: "https://livekit.your-domain.com"
```

- **matrix_homeserver_url**: URL of your Matrix homeserver
- **matrix_widget_url**: URL where LiveKit will be accessible for Matrix clients

#### Logging

- **log_level**: Logging verbosity (`debug`, `info`, `warn`, `error`)
- **verbose**: Enable verbose logging (overrides log_level to `debug`)

#### Advanced Settings

- **external_ip**: Specify external IP for WebRTC (auto-detected if empty)
- **use_ice_lite**: Enable ICE Lite mode for simplified ICE negotiation
- **webhook_urls**: List of URLs to receive LiveKit events

## Matrix/Synapse Integration

### Step 1: Configure LiveKit Add-on

Set up the add-on with Matrix integration:

```yaml
api_key: "matrix_livekit"
api_secret: "your-secure-secret-32-characters-long"
domain: "your-domain.com"
use_ssl: true
cert_file: "fullchain.pem"
pkey_file: "privkey.pem"
matrix_homeserver_url: "https://matrix.your-domain.com"
matrix_widget_url: "https://livekit.your-domain.com"
turn_enabled: true
turn_servers:
  - "turn:your-domain.com:3478"
  - "turns:your-domain.com:5349"
turn_static_auth_secret: "your-coturn-secret"
```

### Step 2: Configure Synapse Homeserver

Add these configurations to your Synapse `homeserver.yaml`:

```yaml
# Enable group calls
experimental_features:
  msc3401_group_calls: true

# Configure LiveKit for group calls
group_calls:
  livekit_url: "https://livekit.your-domain.com"
  livekit_api_key: "matrix_livekit"
  livekit_api_secret: "your-secure-secret-32-characters-long"
```

### Step 3: Client Configuration

Configure your Matrix clients to use LiveKit:

**Element Web/Desktop:**
Add to your Element config:
```json
{
  "livekit": {
    "livekit_service_url": "https://livekit.your-domain.com"
  }
}
```

### Step 4: Test the Integration

1. Start both LiveKit and Matrix add-ons
2. Create a room in your Matrix client
3. Start a group call
4. Verify that LiveKit is handling the call

## Network Configuration

### Understanding Port Usage with TURN Servers

**Important**: When running both LiveKit and a TURN server (like Coturn), you need to understand how ports are used:

**LiveKit Direct Media Ports (40000-40099)**:
- Used for direct WebRTC connections between clients and LiveKit
- When clients can connect directly without NAT traversal

**TURN Server Media Relay Ports (49152-65535)**:
- Used by Coturn to relay media when direct connections fail
- Clients behind strict NATs/firewalls use these ports

**How this works**:
1. **Direct connections**: Clients connect directly to LiveKit (uses 40000-40099)
2. **NAT/Firewall fallback**: Clients can be configured to use your TURN server separately
3. **Note**: TURN integration with LiveKit configuration is coming in a future version

### Port Requirements

LiveKit requires the following ports to be accessible:

- **7880/tcp**: HTTP API and WebRTC signaling
- **7881/tcp**: RTC TCP port
- **40000-40099/udp**: Direct WebRTC media streams (non-overlapping with TURN)

### Firewall Configuration

If you're running LiveKit behind a firewall:

1. **Allow inbound TCP traffic** on your configured HTTP port (default: 7880)
2. **Allow inbound TCP traffic** on your configured RTC TCP port (default: 7881)
3. **Allow inbound UDP traffic** on your configured UDP port range (default: 40000-40099)

**Note**: Your TURN server (Coturn) should also have its ports open (3478, 5349, and 49152-65535).

### Router Configuration

For external access, configure port forwarding on your router:

- Forward external port 7880 → LiveKit HTTP port
- Forward external port 7881 → LiveKit RTC TCP port
- Forward external UDP range → LiveKit UDP port range

## Troubleshooting

### Common Issues

**1. Cannot connect to LiveKit**
- Check that the add-on is running and ports are accessible
- Verify firewall and router configuration
- Check SSL certificate configuration if using HTTPS

**2. WebRTC connection fails**
- Ensure UDP ports are open and forwarded
- Check TURN server configuration
- Verify external IP detection

**3. Matrix integration not working**
- Verify Matrix homeserver configuration
- Check API key and secret match between LiveKit and Synapse
- Ensure both services can reach each other

**4. SSL/Certificate errors**
- Verify certificate files exist in `/ssl/` directory
- Check certificate validity and domain matching
- Ensure private key permissions are correct

### Logs

Enable verbose logging for debugging:

```yaml
verbose: true
log_level: "debug"
```

View logs in the Home Assistant add-on logs section.

### Testing WebRTC Connectivity

Use online WebRTC testing tools to verify your setup:
- https://test.webrtc.org/
- https://webrtc.github.io/samples/src/content/peerconnection/trickle-ice/

## Security Considerations

### API Security

- **Use strong API secrets**: Minimum 32 characters, randomly generated
- **Rotate secrets regularly**: Update API secrets periodically
- **Limit access**: Use firewalls to restrict access to trusted networks

### Network Security

- **Use SSL/TLS**: Always enable SSL for production deployments
- **Secure TURN server**: Use secure TURN server credentials
- **Network isolation**: Consider network segmentation for sensitive deployments

### Matrix Security

- **Verify integration**: Ensure Matrix homeserver properly validates LiveKit tokens
- **Monitor usage**: Keep track of LiveKit usage and active sessions

## Performance Optimization

### Resource Usage

- **CPU**: Scales with concurrent sessions and video quality
- **Memory**: Approximately 10-50MB per concurrent session
- **Bandwidth**: Depends on video quality and number of participants

### Optimization Tips

1. **Limit UDP port range**: Use smaller range if bandwidth is limited
2. **Use ICE Lite**: Enable for controlled network environments
3. **Configure quality settings**: Adjust video quality based on available bandwidth
4. **Monitor performance**: Use Home Assistant system monitoring

## Advanced Configuration

### Custom Webhooks

Configure webhooks to receive LiveKit events:

```yaml
webhook_urls:
  - "https://your-webhook-server.com/livekit-events"
```

### External IP Detection

For complex network setups:

```yaml
external_ip: "your.external.ip.address"
```

### ICE Lite Mode

For simplified ICE negotiation:

```yaml
use_ice_lite: true
```

This mode is useful in controlled network environments where the server has a public IP.

## License

MIT License - see LICENSE file for details.
