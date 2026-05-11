#!/usr/bin/env bash
set -euo pipefail

# VPS Toolbox: interactive script collection for Debian/Ubuntu servers.
# Third-party scripts run as root. Review commands before confirming.

SCRIPT_VERSION="1.0.0"

C_RESET='\033[0m'
C_RED='\033[31m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_BLUE='\033[34m'
C_CYAN='\033[36m'
C_DIM='\033[2m'

color() { printf "%b%s%b" "$1" "$2" "$C_RESET"; }
line() { color "$C_CYAN" "============================================"; echo; }
section() { echo; color "$C_BLUE" "=== $1 ==="; echo; }

require_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    echo "请使用 root 用户运行。"
    exit 1
  fi
}

random_port() {
  shuf -i 20000-65535 -n 1
}

ask_port() {
  local prompt="${1:-请输入 SSH 端口}"
  local port
  while true; do
    read -rp "$prompt（回车随机）: " port
    if [[ -z "$port" ]]; then
      port="$(random_port)"
      echo "已随机端口：$port"
      printf '%s' "$port"
      return 0
    fi
    if [[ "$port" =~ ^[0-9]+$ ]] && (( port >= 1 && port <= 65535 )); then
      printf '%s' "$port"
      return 0
    fi
    echo "端口无效，请输入 1-65535。"
  done
}

ask_password() {
  local prompt="${1:-请输入 root 密码}"
  local pass pass2
  while true; do
    read -rsp "$prompt: " pass; echo
    [[ -n "$pass" ]] || { echo "密码不能为空。"; continue; }
    read -rsp "再次确认密码: " pass2; echo
    [[ "$pass" == "$pass2" ]] || { echo "两次输入不一致。"; continue; }
    printf '%s' "$pass"
    return 0
  done
}

confirm_and_run() {
  local cmd="$1"
  echo
  color "$C_YELLOW" "即将执行："; echo
  echo "$cmd"
  echo
  read -rp "确认执行？[y/N] " ans
  case "$ans" in
    y|Y|yes|YES) bash -lc "$cmd" ;;
    *) echo "已取消" ;;
  esac
}

confirm_and_run_block() {
  local title="$1"
  local script="$2"
  echo
  color "$C_YELLOW" "即将执行：$title"; echo
  echo "----------------------------------------"
  echo "$script"
  echo "----------------------------------------"
  echo
  read -rp "确认执行？[y/N] " ans
  case "$ans" in
    y|Y|yes|YES) bash -s <<< "$script" ;;
    *) echo "已取消" ;;
  esac
}

pause() { echo; read -rp "按回车返回菜单..." _; }

status_text() {
  if command -v curl >/dev/null 2>&1; then
    color "$C_GREEN" "已安装"
  else
    color "$C_RED" "缺少 curl"
  fi
}

running_text() {
  if command -v systemctl >/dev/null 2>&1 && systemctl is-system-running >/dev/null 2>&1; then
    color "$C_GREEN" "正常"
  else
    color "$C_YELLOW" "未知/非 systemd"
  fi
}

menu() {
  clear 2>/dev/null || true
  line
  color "$C_CYAN" " VPS Toolbox"; echo
  color "$C_DIM" " 常用 VPS 脚本集合 | v${SCRIPT_VERSION}"; echo
  line
  printf "安装状态: "; status_text; echo
  printf "运行状态: "; running_text; echo

  section "系统重装 / 初始化"
  echo "  1) DD Debian 13 - bin456789 reinstall"
  echo "  2) DD Debian 13 - InstallNET 备用"
  echo "  3) 新机初始化（通用安全版）"
  echo "  4) 安装常用基础包"
  echo "  5) 启用 systemd-timesyncd 时间同步"

  section "体检 / 跑分"
  echo "  6) NodeQuality"
  echo "  7) Check.Place -H"
  echo "  8) YABS"
  echo "  9) bench.sh"
  echo " 10) LemonBench fast"

  section "IP / 解锁"
  echo " 11) IP.Check.Place"
  echo " 12) check.unlock.media"
  echo " 13) RegionRestrictionCheck"
  echo " 14) OpenAI Checker"

  section "网络 / 路由"
  echo " 15) 安装 Ookla speedtest 并测速"
  echo " 16) latency.sh"
  echo " 17) 安装 tcping"
  echo " 18) 安装 NextTrace"
  echo " 19) 安装 mtr"

  section "转发 / 面板 / Docker"
  echo " 20) Realm"
  echo " 21) 安装 Docker"
  echo " 22) 安装 1Panel"

  section "安全 / 优化"
  echo " 23) BBR 32MB 缓冲"
  echo " 24) BBR 64MB 缓冲"
  echo " 25) 安装 UFW 并放行 SSH/80/443"
  echo " 26) 安装 Fail2ban"

  section "节点脚本"
  echo " 27) AnyTLS Manager"
  echo " 28) SS-Rust Manager"
  echo " 29) Xray Manager"

  section "系统功能"
  echo "  0) 退出"
  echo
  read -rp "请选择编号: " choice
}

BBR_32='cat > /etc/sysctl.d/99-custom.conf << EOF_SYSCTL
fs.file-max = 6815744
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_ecn=0
net.ipv4.tcp_frto=0
net.ipv4.tcp_mtu_probing=0
net.ipv4.tcp_rfc1337=0
net.ipv4.tcp_sack=1
net.ipv4.tcp_fack=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_adv_win_scale=1
net.ipv4.tcp_moderate_rcvbuf=1
net.core.rmem_max=33554432
net.core.wmem_max=33554432
net.ipv4.tcp_rmem=4096 87380 33554432
net.ipv4.tcp_wmem=4096 16384 33554432
net.ipv4.udp_rmem_min=8192
net.ipv4.udp_wmem_min=8192
net.ipv4.ip_forward=1
net.ipv4.conf.all.route_localnet=1
net.ipv4.conf.all.forwarding=1
net.ipv4.conf.default.forwarding=1
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv6.conf.all.forwarding=1
net.ipv6.conf.default.forwarding=1
EOF_SYSCTL
sysctl --system'

BBR_64="${BBR_32//33554432/67108864}"

run_dd_bin456789() {
  local port pass
  port="$(ask_port '请输入 DD 后 SSH 端口')"
  pass="$(ask_password '请输入 DD 后 root 密码')"
  confirm_and_run "wget -O reinstall.sh https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && chmod +x reinstall.sh && ./reinstall.sh debian 13 --password '$pass' --ssh-port '$port' && reboot"
}

run_dd_installnet() {
  local port pass
  port="$(ask_port '请输入 DD 后 SSH 端口')"
  pass="$(ask_password '请输入 DD 后 root 密码')"
  confirm_and_run "wget --no-check-certificate -qO InstallNET.sh 'https://raw.githubusercontent.com/leitbogioro/Tools/master/Linux_reinstall/InstallNET.sh' && chmod a+x InstallNET.sh && bash InstallNET.sh -debian 13 -pwd '$pass' -port '$port'"
}

run_init() {
  local port
  port="$(ask_port '请输入新的 SSH 端口')"
  confirm_and_run_block "新机初始化（通用安全版）" "set -e
apt update
apt install -y curl wget vim nano sudo unzip tar gzip ca-certificates gnupg lsb-release htop iftop iotop nethogs dnsutils iproute2 net-tools socat jq git screen tmux cron openssh-server
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.\$(date +%Y%m%d-%H%M%S)
sed -i -E 's/^#?Port .*/Port ${port}/' /etc/ssh/sshd_config
if ! grep -q '^Port ' /etc/ssh/sshd_config; then echo 'Port ${port}' >> /etc/ssh/sshd_config; fi
systemctl restart ssh || systemctl restart sshd
systemctl enable --now cron || true
echo '初始化完成。SSH 端口：${port}'"
}

while true; do
  menu
  case "${choice}" in
    1) run_dd_bin456789 ;;
    2) run_dd_installnet ;;
    3) run_init ;;
    4) confirm_and_run "apt update && apt install -y curl wget vim nano sudo unzip tar gzip ca-certificates gnupg lsb-release htop iftop iotop nethogs dnsutils iproute2 net-tools socat jq git screen tmux cron" ;;
    5) confirm_and_run "apt install systemd-timesyncd -y && systemctl enable --now systemd-timesyncd" ;;
    6) confirm_and_run "bash <(curl -sL https://run.NodeQuality.com)" ;;
    7) confirm_and_run "bash <(curl -sL https://Check.Place) -H" ;;
    8) confirm_and_run "curl -sL yabs.sh | bash" ;;
    9) confirm_and_run "wget -qO- bench.sh | bash" ;;
    10) confirm_and_run "curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s fast" ;;
    11) confirm_and_run "bash <(curl -sL IP.Check.Place)" ;;
    12) confirm_and_run "bash <(curl -L -s check.unlock.media)" ;;
    13) confirm_and_run "bash <(curl -L -s https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/check.sh)" ;;
    14) confirm_and_run "bash <(curl -Ls https://cdn.jsdelivr.net/gh/missuo/OpenAI-Checker/openai.sh)" ;;
    15) confirm_and_run "curl -sL https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && apt-get install speedtest -y && speedtest" ;;
    16) confirm_and_run "wget -O latency.sh https://raw.githubusercontent.com/Cd1s/network-latency-tester/main/latency.sh && chmod +x latency.sh && ./latency.sh" ;;
    17) confirm_and_run "apt install tcptraceroute -y && wget http://www.vdberg.org/~richard/tcpping -O /usr/bin/tcping && chmod +x /usr/bin/tcping" ;;
    18) confirm_and_run "bash <(curl -Ls https://raw.githubusercontent.com/nxtrace/NTrace-core/main/nt_install.sh)" ;;
    19) confirm_and_run "apt install mtr-tiny -y" ;;
    20) confirm_and_run "curl -L -s realm.shuijiao.de > /root/realm.sh && chmod +x /root/realm.sh && ./realm.sh" ;;
    21) confirm_and_run "curl -fsSL https://get.docker.com | bash && systemctl enable --now docker" ;;
    22) confirm_and_run "curl -sSL https://resource.fit2cloud.com/1panel/package/v2/quick_start.sh -o quick_start.sh && bash quick_start.sh" ;;
    23) confirm_and_run_block "BBR 32MB 缓冲" "$BBR_32" ;;
    24) confirm_and_run_block "BBR 64MB 缓冲" "$BBR_64" ;;
    25) port="$(ask_port '请输入当前 SSH 端口')"; confirm_and_run "apt install ufw -y && ufw allow '${port}'/tcp && ufw allow 80/tcp && ufw allow 443/tcp && ufw enable && ufw status verbose" ;;
    26) confirm_and_run "apt install fail2ban -y && systemctl enable --now fail2ban && systemctl status fail2ban --no-pager" ;;
    27) confirm_and_run "curl -L -s anytls.shuijiao.de > /root/anytls.sh && chmod +x /root/anytls.sh && ./anytls.sh" ;;
    28) confirm_and_run "curl -L -s ss.shuijiao.de > /root/ss-rust.sh && chmod +x /root/ss-rust.sh && ./ss-rust.sh" ;;
    29) confirm_and_run "curl -L -s xray.shuijiao.de > /root/xray.sh && chmod +x /root/xray.sh && ./xray.sh" ;;
    0) exit 0 ;;
    *) echo "无效编号" ;;
  esac
  pause
done
