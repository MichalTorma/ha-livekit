# Home Assistant Add-on: LiveKit Server

A Home Assistant add-on that provides a LiveKit server for real-time video, audio, and data communication with Matrix/Synapse integration support.

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armhf Architecture][armhf-shield]
![Supports armv7 Architecture][armv7-shield]
![Supports i386 Architecture][i386-shield]

## About

LiveKit is an open-source platform for building real-time video, audio, and data experiences. This add-on provides an easy way to run LiveKit within your Home Assistant environment, with special support for Matrix/Synapse integration for group calls.

### Features

- **Real-time Communication**: Support for video, audio, and data streams
- **Matrix Integration**: Seamless integration with Matrix/Synapse for group calls
- **WebRTC Support**: Full WebRTC implementation with NAT traversal
- **TURN Server Integration**: Compatible with Coturn and other TURN servers
- **Secure Authentication**: JWT-based authentication with configurable API keys
- **SSL/TLS Support**: Secure connections with custom SSL certificates
- **Flexible Configuration**: Comprehensive configuration options for production use
- **Multi-Architecture**: Support for various CPU architectures

## Installation

1. Navigate in your Home Assistant frontend to **Settings** → **Add-ons** → **Add-on Store**.
2. Add this repository by clicking the menu in the top-right and selecting **Repositories**.
3. Add the URL: `https://github.com/MichalTorma/ha-repository`
4. Find the "LiveKit Server" add-on and click it.
5. Click on the "INSTALL" button.

## How to use

1. Configure the add-on according to your needs (see Configuration section).
2. Start the add-on.
3. Configure your Matrix homeserver to use LiveKit for group calls.
4. Access LiveKit through your configured domain and port.

### Basic Configuration

The minimal configuration requires setting up API credentials:

```yaml
api_key: "your-api-key"
api_secret: "your-very-long-random-secret-at-least-32-characters"
domain: "homeassistant.local"
```

### Matrix/Synapse Integration

To integrate with Matrix/Synapse for group calls:

```yaml
api_key: "your-api-key"
api_secret: "your-very-long-random-secret-at-least-32-characters"
domain: "your-domain.com"
matrix_homeserver_url: "https://matrix.your-domain.com"
matrix_widget_url: "https://livekit.your-domain.com"
use_ssl: true
cert_file: "fullchain.pem"
pkey_file: "privkey.pem"
```

### Production Configuration with TURN

For production use with TURN server support (using Coturn add-on):

```yaml
api_key: "your-api-key"
api_secret: "your-very-long-random-secret-at-least-32-characters"
domain: "your-domain.com"
use_ssl: true
cert_file: "fullchain.pem"
pkey_file: "privkey.pem"
turn_enabled: true
turn_servers:
  - "turn:your-domain.com:3478"
  - "turns:your-domain.com:5349"
turn_static_auth_secret: "your-coturn-static-secret"
external_ip: "your-external-ip"
```

## Configuration

For detailed configuration options, see the [DOCS.md](DOCS.md) file.

## Matrix Integration

This add-on is designed to work seamlessly with Matrix homeservers like Synapse. For detailed Matrix integration instructions, including homeserver configuration and widget setup, see the [DOCS.md](DOCS.md) file.

## Support

Got questions? Please use the [GitHub Issues][issues] for this repository.

## License

MIT License - see [LICENSE] file for details.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[issues]: https://github.com/MichalTorma/ha-livekit/issues
[LICENSE]: https://github.com/MichalTorma/ha-livekit/blob/main/LICENSE