# VPS-Toolbox

![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white)
![Version](https://img.shields.io/badge/version-v0.1.2-blue?style=flat-square)

[中文](README.md) | **English**

**Common VPS script toolbox.**

> Designed for Debian / Ubuntu root environments. The short install URL is the preferred entry point.

---

## 🎯 Features

- OS reinstall / initialization entries
- Benchmark, IP quality, unlock and route tests
- Forwarding, Docker and hardening helpers
- Show command and ask for confirmation before execution

---

## 🚀 Quick Start

```bash
bash <(curl -Ls https://vps.shuijiao.de)
```

Fallback:

```bash
bash <(curl -Ls https://raw.githubusercontent.com/shuijiao1/VPS-Toolbox/main/vps-toolbox.sh)
```

---

## ⚙️ Versioning and Releases

- Current version: `v0.1.2`
- Changelog: [`CHANGELOG.md`](CHANGELOG.md)
- GitHub Releases are generated from `CHANGELOG.md`
- Maintainers can publish a new version with:

```bash
./release.sh <version> "release notes"
```

---

## ⚠️ Notes

- Run as root only on trusted VPS instances.
- Keep an existing SSH session open before changing firewall, SSH, reinstall, or forwarding settings.
- Public scripts do not include private keys, private passwords, or personal-only initialization logic.
