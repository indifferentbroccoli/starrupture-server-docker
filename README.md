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
      - 7777:7777/tcp
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
    -p 7777:7777/tcp \
    --env-file .env \
    -v ./server-files:/home/steam/server-files \
    indifferentbroccoli/starrupture-server-docker
```

## Environment Variables

You can use the following values to change the settings of the server on boot.

| Variable          | Default              | Info                                                                                                      |
|-------------------|----------------------|-----------------------------------------------------------------------------------------------------------|
| PUID              | 1000                 | User ID for file permissions                                                                              |
| PGID              | 1000                 | Group ID for file permissions                                                                             |
| SERVER_NAME       | starrupture-server   | Name of the server                                                                                        |
| DEFAULT_PORT      | 7777                 | The port the server listens on (UDP + TCP)                                                                      |
| MULTIHOME         |                      | Optional: Bind to a specific network interface IP address                                                 |
| MAX_PLAYERS       |                      | Optional: Max players via `-MaxPlayers` launch arg. StarRupture's stable cap is 4; leave blank for default. Unofficial flag — values above 4 are reported to cause desync/crashes |
| UPDATE_ON_START   | true                 | If set to false, skips downloading and validating server files from Steam on startup                      |
| USE_DSSETTINGS    | false                | Enable/disable DSSettings.txt generation. If false, you must forward port 7777 TCP (security risk!)       |
| ADMIN_PASSWORD    |                      | Admin password (automatically encrypted and saved to Password.json)                                       |
| PLAYER_PASSWORD   |                      | Player join password (automatically encrypted and saved to PlayerPassword.json)                           |
| SESSION_NAME      | StarRuptureServer    | Save game session name (max 20 characters)                                                                |
| SAVE_GAME_INTERVAL| 300                  | Auto-save interval in seconds                                                                             |
| START_NEW_GAME    | false                | Create a new world on startup ("true" or "false")                                                        |
| LOAD_SAVED_GAME   | true                 | Load existing save game on startup ("true" or "false")                                                   |
| SAVE_GAME_NAME    | AutoSave0.sav        | Name of the save file to load                                                                             |

## Connecting to Your Server

1. **Start the server** using Docker Compose or Docker Run
2. **Launch StarRupture** on your gaming PC
3. **Go to "Manage Server"** in the game menu
4. **Enter your server's external IP address** (or localhost if testing locally)
5. **Create a new world** by clicking "New" and naming your server
6. **Load the world** by clicking "Load Server" and selecting your world
7. **Join the game** by going back and selecting "Join Game", then entering your server IP

## Port Forwarding

> [!CAUTION]
> **Default (Secure)**: Forward **7777 UDP only**
> 
> **If `USE_DSSETTINGS=false`**: Must forward **7777 UDP + TCP** - this exposes a critical remote control vulnerability. See [vulnerability disclosure](https://wiki.starrupture-utilities.com/en/dedicated-server/Vulnerability-Announcement).

## Server Configuration (DSSettings.txt)

> [!IMPORTANT]
> **First Boot**: Set `START_NEW_GAME=true` and `LOAD_SAVED_GAME=false`, join server, save game, then change to `START_NEW_GAME=false` and `LOAD_SAVED_GAME=true`.

Configure save game behavior via environment variables in your `.env` file:

```bash
USE_DSSETTINGS=true          # false (default) = use in-game Server Manager (requires TCP, security risk)
SESSION_NAME=StarRuptureServer
SAVE_GAME_INTERVAL=300
START_NEW_GAME=false         # true on first boot only
LOAD_SAVED_GAME=true         # false on first boot only
SAVE_GAME_NAME=AutoSave0.sav
```

### Setting Passwords

To set admin and player join passwords, add them to your `.env` file:

```bash
ADMIN_PASSWORD=your_admin_password
PLAYER_PASSWORD=your_player_password
```

The container uses the starrupture-utilities.com API to encrypt passwords and generate the required JSON files on startup.

> [!NOTE]
> If the API is unavailable, you can manually generate password files at [https://starrupture-utilities.com/passwords/](https://starrupture-utilities.com/passwords/) and place them in the `server-files/` directory.

### Loading an Existing Save

1. Place `.sav` and `.met` files in `server-files/StarRupture/Saved/SaveGames/[SessionName]/`
2. Rename to `AutoSave0.sav` and `AutoSave0.met`
3. Set matching `SESSION_NAME` in `.env`
4. Ensure `LOAD_SAVED_GAME=true` and `START_NEW_GAME=false`

## Server Management

> [!NOTE]
> With `USE_DSSETTINGS=true`, the in-game Server Manager is disabled for security. Use environment variables to configure your server instead.

If using `USE_DSSETTINGS=false`, you can use the in-game Server Manager by launching StarRupture and going to **Manage Server**.

## Volumes

* `/home/steam/server-files` - Server installation files, configuration, and save files

## Support

For issues and questions:
* GitHub Issues: [Report an issue](https://github.com/indifferentbroccoli/starrupture-server-docker/issues)
* Game Server Hosting: [indifferentbroccoli.com](https://indifferentbroccoli.com)
