# yolks

Container images for Pterodactyl / Wings runtimes that the
[parkervcp/yolks](https://github.com/parkervcp/yolks) collection does not ship.

## Zig

`ghcr.io/ddatunashvili/yolks:zig_<version>`, for `linux/amd64` and `linux/arm64`.

| Tag | Zig |
| --- | --- |
| `zig_latest`, `zig_0.17` | 0.17.0 |
| `zig_0.16` | 0.16.0 |
| `zig_0.15` | 0.15.2 |
| `zig_0.14` | 0.14.1 |

The image carries `zig-start`, which builds the project in `/home/container`
and runs it:

- **[Ziex](https://ziex.dev) apps** (a `build.zig.zon` naming `ziex`):
  `zig build`, `zig build zx -- bundle`, then the bundled binary from
  `.renode-app/`. KV data under that directory survives rebuilds.
- **Anything else with a `build.zig`:** `zig build`, then the executable in
  `zig-out/bin`.

`SERVER_PORT` is exported as `PORT` and `ADDRESS` defaults to `0.0.0.0`, which
is what Ziex listens on. Other settings: `ZIG_OPTIMIZE` (`ReleaseSafe`),
`ZIG_BUILD_ARGS`, `ZIG_BIN`. The Zig package cache lives in
`/home/container/.cache/zig`, so dependencies are fetched once per server.

Images rebuild on push and monthly, for base-image security updates.
