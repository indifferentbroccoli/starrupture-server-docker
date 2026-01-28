<!-- markdownlint-disable-next-line -->
![marketing_assets_banner](https://github.com/user-attachments/assets/b8b4ae5c-06bb-46a7-8d94-903a04595036)
[![GitHub License](https://img.shields.io/github/license/indifferentbroccoli/starrupture-server-docker?style=for-the-badge&color=6aa84f)](https://github.com/indifferentbroccoli/starrupture-server-docker/blob/main/LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/indifferentbroccoli/starrupture-server-docker?style=for-the-badge&color=6aa84f)](https://github.com/indifferentbroccoli/starrupture-server-docker/releases)
[![GitHub Repo stars](https://img.shields.io/github/stars/indifferentbroccoli/starrupture-server-docker?style=for-the-badge&color=6aa84f)](https://github.com/indifferentbroccoli/starrupture-server-docker)
[![Discord](https://img.shields.io/discord/798321161082896395?style=for-the-badge&label=Discord&labelColor=5865F2&color=6aa84f)](https://discord.gg/indifferentbroccoli)
[![Docker Pulls](https://img.shields.io/docker/pulls/indifferentbroccoli/starrupture-server-docker?style=for-the-badge&color=6aa84f)](https://hub.docker.com/r/indifferentbroccoli/starrupture-server-docker)

Game server hosting

Fast RAM, high-speed internet

Eat lag for breakfast

[Try our StarRupture server hosting free for 2 days!](https://indifferentbroccoli.com/star-rupture-server-hosting)

## StarRupture Dedicated Server Docker

A Docker container for running a StarRupture dedicated server using SteamCMD.

## Server Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| CPU      | 4 cores | 4+ cores    |
| RAM      | 8GB     | 16GB        |
| Storage  | 30GB    | 50GB        |

> [!WARNING]
> **Security Vulnerability Mitigation**: This container only exposes UDP ports to prevent a remote control vulnerability that affects the StarRupture dedicated server. Do NOT expose TCP port 7777, as it allows unauthorized remote access to server settings and save files. See [StarRupture Security Announcement](https://wiki.starrupture-utilities.com/en/dedicated-server/Vulnerability-Announcement) for details.

> [!NOTE]
> StarRupture is in Early Access. Server features and requirements may change.

StarRupture does not currently support connecting via a local address. You must configure a hairpin NAT (Some routers do this by default)

## How to use

Copy the .env.example file to a new file called .env. Then use either `docker compose` or `docker run`

### Docker compose

Starting the server with Docker Compose:

```yaml
services:
  starrupture:
    image: indifferentbroccoli/starrupture-server-docker
    restart: unless-stopped
    container_name: starrupture
    stop_grace_period: 30s
    ports:
      - 7777:7777/udp
      - 27015:27015/udp
    env_file:
      - .env
    volumes:
      - ./server-files:/home/steam/server-files
```

Then run:

```bash
docker-compose up -d
```

### Docker Run

```bash
docker run -d \
    --restart unless-stopped \
    --name starrupture \
    --stop-timeout 30 \
    -p 7777:7777/udp \
    -p 27015:27015/udp \
    --env-file .env \
    -v ./server-files:/home/steam/server-files
    indifferentbroccoli/starrupture-server-docker
```

## Environment Variables

You can use the following values to change the settings of the server on boot.

| Variable          | Default              | Info                                                                                                      |
|-------------------|----------------------|-----------------------------------------------------------------------------------------------------------|
| PUID              | 1000                 | User ID for file permissions                                                                              |
| PGID              | 1000                 | Group ID for file permissions                                                                             |
| SERVER_NAME       | starrupture-server   | Name of the server                                                                                        |
| DEFAULT_PORT      | 7777                 | The port the server listens on (UDP only - TCP disabled for security)                                    |
| QUERY_PORT        | 27015                | The query port for server browser and status queries (UDP)                                                |
| MULTIHOME         |                      | Optional: Bind to a specific network interface IP address                                                 |
| UPDATE_ON_START   | true                 | If set to false, skips downloading and validating server files from Steam on startup                      |

## Connecting to Your Server

1. **Start the server** using Docker Compose or Docker Run
2. **Launch StarRupture** on your gaming PC
3. **Go to "Manage Server"** in the game menu
4. **Enter your server's external IP address** (or localhost if testing locally)
5. **Create a new world** by clicking "New" and naming your server
6. **Load the world** by clicking "Load Server" and selecting your world
7. **Join the game** by going back and selecting "Join Game", then entering your server IP

## Port Forwarding

If your server is behind a router, you need to forward the following ports:

* **7777** (UDP only) - Game server port (DO NOT forward TCP - security vulnerability)
* **27015** (UDP) - Query port

> [!WARNING]
> Only forward UDP ports. Forwarding TCP port 7777 exposes your server to a remote control vulnerability.

For more information and instructions specific to your router, visit [portforward.com](https://portforward.com/).

## Server Management

The StarRupture dedicated server uses an in-game management interface:

1. Launch StarRupture on your PC
2. Go to **Manage Server**
3. Enter your server's IP address and password (you will set this on first connection)
4. From here you can create, load, and manage server worlds

## Volumes

* `/home/steam/server-files` - Server installation files, configuration, and save files

## Support

For issues and questions:
* GitHub Issues: [Report an issue](https://github.com/indifferentbroccoli/starrupture-server-docker/issues)
* Game Server Hosting: [indifferentbroccoli.com](https://indifferentbroccoli.com)
