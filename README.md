# Saucebase installer

The one-command way to create a new [Saucebase](https://saucebase.dev) application.

## macOS / Linux

```sh
curl -fsSL https://install.saucebase.dev | bash -s -- my-app
```

## Windows (PowerShell)

```powershell
irm https://install.saucebase.dev/install.ps1 | iex
```

> `iex` can't forward arguments, so it drops you into `saucebase new` and prompts
> for the project name. Or run `saucebase new my-app` yourself afterwards.

## What it does

1. Installs **PHP + Composer** via [php.new](https://php.new) if they aren't already present.
2. Installs the global **`saucebase`** CLI (`composer global require saucebase/installer`).
3. Runs **`saucebase new`** to scaffold and configure your app.

PHP and Composer are the only tools it touches globally — everything else
(Docker services, database, modules) is handled per-project by the CLI.

Already have PHP and Composer? Skip the script entirely:

```sh
composer global require saucebase/installer
saucebase new my-app
```

## Fallback URL

Until `install.saucebase.dev` DNS is wired up, use the raw script directly:

```sh
curl -fsSL https://raw.githubusercontent.com/saucebase/install/main/install.sh | bash -s -- my-app
```

## Hosting

This repo publishes to GitHub Pages via [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml).
Point `install.saucebase.dev` at GitHub Pages with a DNS `CNAME` record → `<org>.github.io`
(the workflow writes the `CNAME` file into the published site). The unix `install.sh` is also
served at the bare root as `index.html`, so `curl -fsSL install.saucebase.dev | bash` works.
