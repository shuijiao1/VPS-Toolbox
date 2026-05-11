# VPS Toolbox

常用 VPS 脚本集合，默认面向 Debian / Ubuntu root 环境。

> 第三方一键脚本会以 root 权限执行。请先确认来源和风险，重要机器建议先读脚本再运行。

## 一键运行

```bash
bash <(curl -Ls https://vps.shuijiao.de)
```

GitHub Raw 备用：

```bash
bash <(curl -Ls https://raw.githubusercontent.com/shuijiao1/VPS-Toolbox/main/vps-toolbox.sh)
```

## 功能分类

### 系统重装 / 初始化

- DD Debian 13 - bin456789 reinstall
- DD Debian 13 - InstallNET 备用
- 新机初始化（通用安全版）
- 安装常用基础包
- 启用 systemd-timesyncd 时间同步

说明：

- DD 端口由用户输入，直接回车会随机生成端口。
- DD root 密码由用户交互输入，不在脚本中内置。
- 初始化只做通用基础配置和 SSH 端口修改，不下载私人密钥。
- 初始化 SSH 端口由用户输入，直接回车会随机生成端口。

### 体检 / 跑分

- NodeQuality
- Check.Place -H
- YABS
- bench.sh
- LemonBench fast

### IP / 解锁

- IP.Check.Place
- check.unlock.media
- RegionRestrictionCheck
- OpenAI Checker

### 网络 / 路由

- Ookla speedtest
- latency.sh
- tcping
- NextTrace
- mtr

### 转发 / 面板 / Docker

- Realm
- Docker
- 1Panel

### 安全 / 优化

- BBR 32MB 缓冲
- BBR 64MB 缓冲
- UFW：交互输入当前 SSH 端口并放行 SSH / 80 / 443
- Fail2ban

### 节点脚本

- AnyTLS Manager
- SS-Rust Manager
- Xray Manager

## 菜单风格

脚本采用交互式菜单：

- 高亮青色顶部框
- 标题 + 版本 + 状态压缩展示
- 黄绿色紧凑分类菜单，减少滚屏
- 执行前展示命令并要求确认

## 风险提示

- DD / 重装脚本会清空系统，执行前确认 IP、端口、密码、控制台/救援模式可用。
- 防火墙、SSH、内核、BBR、转发规则改动前，建议保留一个现有 SSH 会话不断开。
- 公共版脚本不包含私人密钥、固定私人密码或个人初始化逻辑。
