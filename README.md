# tor-proxy

Container image for a Tor SOCKS proxy that connects through bridges
(webtunnel, obfs4 and other pluggable transports). Based on Alpine with `tor`,
`lyrebird` and `obfs4proxy` from the Alpine edge repositories, so webtunnel is
supported out of the box.

## Design

The image deliberately ships **without a `torrc`**. Configuration and the bridge list are
supplied at runtime by mounting a config file at `/etc/tor/torrc`. Bridges tend to die and
need replacing often; keeping them out of the image means swapping a bridge never
requires a rebuild, and no bridge lines end up in a public image.

## Usage

```sh
docker run --rm \
  -v "$PWD/torrc:/etc/tor/torrc:ro" \
  -p 9150:9150 \
  ghcr.io/kbnchk/tor-proxy:<tag>
```

Minimal `torrc` with webtunnel bridges:

```
SocksPort 0.0.0.0:9150
DataDirectory /var/lib/tor
Log notice stdout

UseBridges 1
ClientTransportPlugin webtunnel,obfs4 exec /usr/bin/lyrebird
Bridge webtunnel <address> <fingerprint> url=https://<bridge-host>/<path> ver=0.0.3
```

Notes:

- The container runs as the unprivileged `tor` user. `/var/lib/tor` (`DataDirectory`)
  must be writable by that user and have mode `0700`; when mounting a volume, fix its
  ownership first (for example with an init step: `chown tor:tor /var/lib/tor && chmod 700 /var/lib/tor`).
- Ports: `9150/tcp` (SOCKS) and `8853/udp` (DNSPort, only if enabled in `torrc`).
- Health check example:
  `curl --fail --socks5-hostname 127.0.0.1:9150 https://check.torproject.org/api/ip`

## Image tags

GitHub Actions (`.github/workflows/build.yaml`) builds and pushes to
`ghcr.io/kbnchk/tor-proxy`:

- `YYYYMMDD-<short-sha>` — immutable tag; pin this one in deployments;
- `latest` — moving tag, not recommended for production.

A build runs on every change to the `Dockerfile` or the workflow, on manual dispatch, and
monthly (1st day, 03:00 UTC) to pick up Alpine and Tor security updates. After each build
only the 3 most recent package versions are kept; older ones are deleted from GHCR.

## License

See [LICENSE](LICENSE).
