#!/usr/bin/env bash
set -euo pipefail

# VPS Toolbox: interactive script collection for Debian/Ubuntu servers.
# Third-party scripts run as root. Review commands before confirming.

SCRIPT_VERSION="1.0.0"

C_RESET='\033[0m'
C_RED='\033[1;31m'
C_GREEN='\033[1;32m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[1;34m'
C_CYAN='\033[1;36m'
C_MAGENTA='\033[1;35m'
C_WHITE='\033[1;37m'
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

banner() {
  clear 2>/dev/null || true
  echo
  color "$C_CYAN" "╭──────────────────────────────────────╮"; echo
  color "$C_CYAN" "│"; color "$C_WHITE" "  VPS Toolbox"; color "$C_DIM" "  v${SCRIPT_VERSION}"; printf "%16s" ""; color "$C_CYAN" "│"; echo
  color "$C_CYAN" "│"; color "$C_GREEN" "  常用 VPS 脚本集合"; printf "%18s" ""; color "$C_CYAN" "│"; echo
  color "$C_CYAN" "╰──────────────────────────────────────╯"; echo
  printf "  "; color "$C_DIM" "状态"; printf "  "; status_text; printf "  "; color "$C_DIM" "·"; printf "  "; running_text; echo
  echo
}

main_menu() {
  banner
  color "$C_YELLOW" "  1"; echo "  系统重装 / 初始化"
  color "$C_YELLOW" "  2"; echo "  体检 / 跑分"
  color "$C_YELLOW" "  3"; echo "  IP / 解锁检测"
  color "$C_YELLOW" "  4"; echo "  网络 / 路由工具"
  color "$C_YELLOW" "  5"; echo "  服务 / 面板 / Docker"
  color "$C_YELLOW" "  6"; echo "  安全优化 / 节点脚本"
  echo
  color "$C_GREEN" "  0"; echo "  退出"
  echo
  read -rp "请选择分类: " choice
}

submenu_header() {
  local title="$1"
  banner
  color "$C_MAGENTA" "  $title"; echo
  color "$C_DIM" "  ────────────────────────────────────"; echo
}

menu_system() {
  submenu_header "系统重装 / 初始化"
  echo "  1) DD Debian 13 - bin456789"
  echo "  2) DD Debian 13 - InstallNET 备用"
  echo "  3) 新机初始化（通用安全版）"
  echo "  4) 安装常用基础包"
  echo "  5) 启用时间同步"
  echo
  echo "  b) 返回"
  echo
  read -rp "请选择编号: " choice
  case "$choice" in b|B) return 0 ;; 1|2|3|4|5) run_choice "$choice" ;; *) echo "无效编号"; pause ;; esac
}

menu_bench() {
  submenu_header "体检 / 跑分"
  echo "  6) NodeQuality"
  echo "  7) Check.Place -H"
  echo "  8) YABS"
  echo "  9) bench.sh"
  echo " 10) LemonBench fast"
  echo
  echo "  b) 返回"
  echo
  read -rp "请选择编号: " choice
  case "$choice" in b|B) return 0 ;; 6|7|8|9|10) run_choice "$choice" ;; *) echo "无效编号"; pause ;; esac
}

menu_ip() {
  submenu_header "IP / 解锁检测"
  echo " 11) IP.Check.Place"
  echo " 12) check.unlock.media"
  echo " 13) RegionRestrictionCheck"
  echo " 14) OpenAI Checker"
  echo
  echo "  b) 返回"
  echo
  read -rp "请选择编号: " choice
  case "$choice" in b|B) return 0 ;; 11|12|13|14) run_choice "$choice" ;; *) echo "无效编号"; pause ;; esac
}

menu_network() {
  submenu_header "网络 / 路由工具"
  echo " 15) Ookla speedtest"
  echo " 16) latency.sh"
  echo " 17) tcping"
  echo " 18) NextTrace"
  echo " 19) mtr"
  echo
  echo "  b) 返回"
  echo
  read -rp "请选择编号: " choice
  case "$choice" in b|B) return 0 ;; 15|16|17|18|19) run_choice "$choice" ;; *) echo "无效编号"; pause ;; esac
}

menu_service() {
  submenu_header "服务 / 面板 / Docker"
  echo " 20) Realm"
  echo " 21) Docker"
  echo " 22) 1Panel"
  echo
  echo "  b) 返回"
  echo
  read -rp "请选择编号: " choice
  case "$choice" in b|B) return 0 ;; 20|21|22) run_choice "$choice" ;; *) echo "无效编号"; pause ;; esac
}

menu_security() {
  submenu_header "安全优化 / 节点脚本"
  echo " 23) BBR 32MB 缓冲"
  echo " 24) BBR 64MB 缓冲"
  echo " 25) UFW 放行 SSH / 80 / 443"
  echo " 26) Fail2ban"
  echo " 27) AnyTLS Manager"
  echo " 28) SS-Rust Manager"
  echo " 29) Xray Manager"
  echo
  echo "  b) 返回"
  echo
  read -rp "请选择编号: " choice
  case "$choice" in b|B) return 0 ;; 23|24|25|26|27|28|29) run_choice "$choice" ;; *) echo "无效编号"; pause ;; esac
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

run_choice() {
  case "${1}" in
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
    20) confirm_and_run "bash <(curl -Ls https://realm.shuijiao.de)" ;;
    21) confirm_and_run "curl -fsSL https://get.docker.com | bash && systemctl enable --now docker" ;;
    22) confirm_and_run "curl -sSL https://resource.fit2cloud.com/1panel/package/v2/quick_start.sh -o quick_start.sh && bash quick_start.sh" ;;
    23) confirm_and_run_block "BBR 32MB 缓冲" "$BBR_32" ;;
    24) confirm_and_run_block "BBR 64MB 缓冲" "$BBR_64" ;;
    25) port="$(ask_port '请输入当前 SSH 端口')"; confirm_and_run "apt install ufw -y && ufw allow '${port}'/tcp && ufw allow 80/tcp && ufw allow 443/tcp && ufw enable && ufw status verbose" ;;
    26) confirm_and_run "apt install fail2ban -y && systemctl enable --now fail2ban && systemctl status fail2ban --no-pager" ;;
    27) confirm_and_run "bash <(curl -Ls https://anytls.shuijiao.de)" ;;
    28) confirm_and_run "bash <(curl -Ls https://ss.shuijiao.de)" ;;
    29) confirm_and_run "bash <(curl -Ls https://xray.shuijiao.de)" ;;
  esac
 
  pause
}

while true; do
  main_menu
  case "${choice}" in
    1) menu_system ;;
    2) menu_bench ;;
    3) menu_ip ;;
    4) menu_network ;;
    5) menu_service ;;
    6) menu_security ;;
    0) exit 0 ;;
    *) echo "无效分类"; pause ;;
  esac
done
