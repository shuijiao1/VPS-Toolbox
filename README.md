# VPS-Toolbox

![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white)
![Version](https://img.shields.io/badge/version-v0.1.4-blue?style=flat-square)

**中文** | [English](README.en.md)

**常用 VPS 脚本集合。**

> 面向 Debian / Ubuntu root 环境，优先使用自己的短链一键运行。

---

## 🎯 核心特性

- 系统重装 / 初始化入口
- 跑分、IP 质量、解锁和路由测试
- 转发、Docker、安全优化常用脚本
- 执行前展示命令并确认

---

## 🚀 快速开始

```bash
bash <(curl -Ls https://vps.shuijiao.de)
```

---

## ⚙️ 版本与发布

- 当前版本：`v0.1.3`
- 更新记录见 [`CHANGELOG.md`](CHANGELOG.md)
- GitHub Release 会根据 `CHANGELOG.md` 自动生成说明
- 维护者发布新版本可使用：

```bash
./release.sh <version> "更新说明"
```

---

## ⚠️ 注意事项

- 请在可信 VPS 上以 root 执行。
- 涉及防火墙、SSH、重装、转发规则等操作前，建议保留一个现有 SSH 会话不断开。
- 脚本默认只维护公开通用配置，不内置私人密钥或私人密码。
