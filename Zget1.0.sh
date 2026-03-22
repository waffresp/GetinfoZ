#!/system/bin/sh

# Zget
# 作者：Huwaff
# 版本：2.0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# 全局变量
IS_ROOT=0
ROOT_STATUS=""

# 标题
print_header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}        Zget v1.0${NC}${CYAN}              ║${NC}"
    echo -e "${CYAN}║${WHITE}        w3${NC}${CYAN}                              ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# 分隔线
print_section() {
    echo -e "${YELLOW}┌────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│${GREEN} $1${NC}${YELLOW}${NC}"                                                                  │
    echo -e "${YELLOW}└────────────────────────────────────────────────┘${NC}"
}

perm_warning() {
    echo -e "${RED} [需要 Root 权限]${NC}"
}

#ROOT检查
check_root() {
    if [ "$(id -u)" = "0" ]; then
        IS_ROOT=1
        ROOT_STATUS="${GREEN}已获取 Root 权限${NC}"
    else
        IS_ROOT=0
        ROOT_STATUS="${RED}未获取 Root 权限/Root不可用${NC}"
    fi
}

#Root状态
show_root_status() {
    print_section "【权限状态】"
    echo -e "${BLUE}当前用户:${NC} $(id -un) (UID: $(id -u))"
    echo -e "${BLUE}Root 状态:${NC} $ROOT_STATUS"
    if [ $IS_ROOT -eq 0 ]; then
        echo -e "${YELLOW}提示：部分功能需要 Root 权限才能完整读取${NC}"
    fi
    echo ""
}

# 主菜单
show_menu() {
    echo -e "${CYAN}┌────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${WHITE}              请选择要查看的信息${NC}${CYAN}                │${NC}"
    echo -e "${CYAN}├────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}0${NC}  - 显示全部信息                              │"
    echo -e "${CYAN}│${NC}  ${GREEN}1${NC}  - 系统基本信息                              │"
    echo -e "${CYAN}│${NC}  ${GREEN}2${NC}  - 硬件信息                                  │"
    echo -e "${CYAN}│${NC}  ${GREEN}3${NC}  - 网络接口信息                              │"
    echo -e "${CYAN}│${NC}  ${GREEN}4${NC}  - WiFi 信息                                 │"
    echo -e "${CYAN}│${NC}  ${GREEN}5${NC}  - 移动网络信息                              │"
    echo -e "${CYAN}│${NC}  ${GREEN}6${NC}  - 网络连接测试                              │"
    echo -e "${CYAN}│${NC}  ${GREEN}7${NC}  - 存储信息                                  │"
    echo -e "${CYAN}│${NC}  ${GREEN}8${NC}  - 电池信息                                  │"
    echo -e "${CYAN}│${NC}  ${GREEN}9${NC}  - 应用信息                                  │"
    echo -e "${CYAN}│${NC}  ${GREEN}10${NC} - 进程信息                                  │"
    echo -e "${CYAN}│${NC}  ${GREEN}11${NC} - 权限状态                                  │"
    echo -e "${CYAN}│${NC}  ${GREEN}12${NC} - 刷新权限状态                              │"
    echo -e "${CYAN}│${NC}  ${GREEN}q${NC}  - 退出程序                                  │"
    echo -e "${CYAN}└────────────────────────────────────────────────┘${NC}"
    echo ""
}

# 获取系统基本信息
get_system_info() {
    print_section "【系统基本信息】"
    
    echo -e "${BLUE}Android 版本:${NC} $(getprop ro.build.version.release)"
    echo -e "${BLUE}SDK 版本:${NC} $(getprop ro.build.version.sdk)"
    echo -e "${BLUE}设备型号:${NC} $(getprop ro.product.model)"
    echo -e "${BLUE}制造商:${NC} $(getprop ro.product.manufacturer)"
    echo -e "${BLUE}品牌:${NC} $(getprop ro.product.brand)"
    echo -e "${BLUE}设备名称:${NC} $(getprop ro.product.device)"
    echo -e "${BLUE}构建版本:${NC} $(getprop ro.build.display.id)"
    echo -e "${BLUE}安全补丁:${NC} $(getprop ro.build.version.security_patch)"
    echo -e "${BLUE}构建时间:${NC} $(getprop ro.build.date)"
    echo -e "${BLUE}主板:${NC} $(getprop ro.product.board)"
    echo -e "${BLUE}平台:${NC} $(getprop ro.board.platform)"
    
    if [ $IS_ROOT -eq 0 ]; then
        echo -e "${RED}部分系统属性需要 Root 权限才能读取${NC}"
    fi
    echo ""
}

#获取硬件信息，没ROOT不可读取
get_hardware_info() {
    print_section "【硬件信息】"
    
    echo -e "${BLUE}CPU ABI:${NC} $(getprop ro.product.cpu.abi)"
    echo -e "${BLUE}CPU ABI2:${NC} $(getprop ro.product.cpu.abi2 2>/dev/null || echo 'N/A')"
    
    #CPU核心数
    if [ -f /sys/devices/system/cpu/online ]; then
        echo -e "${BLUE}CPU 核心数:${NC} $(cat /sys/devices/system/cpu/online | tr '-' ' ' | awk '{print $1+$2+1}')"
    else
        echo -e "${BLUE}CPU 核心数:${NC} $(grep -c processor /proc/cpuinfo)"
    fi
    
    # CPU 频率
    if [ $IS_ROOT -eq 1 ] && [ -f /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq ]; then
        max_freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null)
        echo -e "${BLUE}CPU 最大频率:${NC} $((max_freq / 1000)) MHz"
    else
        echo -e "${BLUE}CPU 最大频率:${NC} $(perm_warning) 需要 Root"
    fi
    
    # 内存信息
    if [ -f /proc/meminfo ]; then
        mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        mem_free=$(grep MemFree /proc/meminfo | awk '{print $2}')
        echo -e "${BLUE}内存总量:${NC} $((mem_total / 1024)) MB"
        echo -e "${BLUE}可用内存:${NC} $((mem_free / 1024)) MB"
    else
        echo -e "${BLUE}内存信息:${NC} $(perm_warning) 无法读取"
    fi
    
    # 屏幕信息
    echo -e "${BLUE}屏幕分辨率:${NC} $(wm size 2>/dev/null | grep -o '[0-9]*x[0-9]*' || echo '无法获取')"
    echo -e "${BLUE}屏幕密度:${NC} $(wm density 2>/dev/null | grep -o '[0-9]*' || echo '无法获取') dpi"
    
    # GPU 信息
    if [ $IS_ROOT -eq 1 ]; then
        gpu=$(getprop ro.hardware.vulkan 2>/dev/null || getprop ro.opengles.version 2>/dev/null)
        echo -e "${BLUE}GPU 信息:${NC} ${gpu:-N/A}"
    else
        echo -e "${BLUE}GPU 信息:${NC} $(perm_warning) 需要 Root"
    fi
    
    echo ""
}

# 获取网络接口信息
get_network_interfaces() {
    print_section "【网络接口信息】"
    
    for iface in $(ls /sys/class/net/ 2>/dev/null); do
        echo -e "${BLUE}├─ 接口:${NC} $iface"
        
        # IP 地址
        ip_addr=$(ip addr show $iface 2>/dev/null | grep "inet " | awk '{print $2}')
        if [ -n "$ip_addr" ]; then
            echo -e "${BLUE}│  └─ IP 地址:${NC} $ip_addr"
        else
            echo -e "${BLUE}│  └─ IP 地址:${NC} 无"
        fi
        
        # MAC 地址
        if [ $IS_ROOT -eq 1 ] || [ "$iface" = "lo" ]; then
            mac_addr=$(cat /sys/class/net/$iface/address 2>/dev/null)
            echo -e "${BLUE}│  └─ MAC 地址:${NC} ${mac_addr:-N/A}"
        else
            echo -e "${BLUE}│  └─ MAC 地址:${NC} $(perm_warning) 需要 Root"
        fi
        
        # 接口状态
        state=$(cat /sys/class/net/$iface/operstate 2>/dev/null)
        echo -e "${BLUE}│  └─ 状态:${NC} ${state:-unknown}"
        
        # 接收/发送字节
        if [ -f /sys/class/net/$iface/statistics/rx_bytes ]; then
            rx=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null)
            tx=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null)
            echo -e "${BLUE}│  └─ 流量:${NC} ↓$((rx/1024/1024))MB ↑$((tx/1024/1024))MB"
        fi
        
        echo ""
    done
}

# 获取 WiFi 信息
get_wifi_info() {
    print_section "【WiFi 信息】"
    
    # WiFi 状态
    wifi_status=$(dumpsys wifi 2>/dev/null | grep "Wi-Fi is" | head -1)
    echo -e "${BLUE}WiFi 状态:${NC} ${wifi_status:-无法获取}"
    
    # 当前连接的 WiFi
    if [ $IS_ROOT -eq 1 ]; then
        wifi_ssid=$(dumpsys wifi 2>/dev/null | grep "SSID:" | head -1 | cut -d':' -f2 | tr -d ' "')
        echo -e "${BLUE}当前 WiFi:${NC} ${wifi_ssid:-未连接}"
        
        # WiFi 信号强度
        wifi_signal=$(dumpsys wifi 2>/dev/null | grep "level:" | head -1 | cut -d':' -f2 | tr -d ' ')
        echo -e "${BLUE}信号强度:${NC} ${wifi_signal:-N/A} dBm"
        
        # WiFi 频率
        wifi_freq=$(dumpsys wifi 2>/dev/null | grep "frequency:" | head -1 | cut -d':' -f2 | tr -d ' ')
        echo -e "${BLUE}WiFi 频率:${NC} ${wifi_freq:-N/A} MHz"
    else
        echo -e "${BLUE}当前 WiFi:${NC} $(perm_warning) 需要 Root"
        echo -e "${BLUE}信号强度:${NC} $(perm_warning) 需要 Root"
        echo -e "${BLUE}WiFi 频率:${NC} $(perm_warning) 需要 Root"
    fi
    
    # WiFi IP
    wifi_ip=$(ip addr show wlan0 2>/dev/null | grep "inet " | awk '{print $2}')
    echo -e "${BLUE}WiFi IP:${NC} ${wifi_ip:-未获取}"
    
    # WiFi MAC
    if [ $IS_ROOT -eq 1 ]; then
        wifi_mac=$(cat /sys/class/net/wlan0/address 2>/dev/null)
        echo -e "${BLUE}WiFi MAC:${NC} ${wifi_mac:-N/A}"
    else
        echo -e "${BLUE}WiFi MAC:${NC} $(perm_warning) 需要 Root"
    fi
    
    echo ""
}

# 获取移动网络信息
get_mobile_info() {
    print_section "【移动网络信息】"
    
    if [ $IS_ROOT -eq 1 ]; then
        # 网络类型
        network_type=$(dumpsys telephony.registry 2>/dev/null | grep "mNetworkType" | head -1 | cut -d'=' -f2)
        echo -e "${BLUE}网络类型:${NC} ${network_type:-N/A}"
        
        # 数据连接状态
        data_state=$(dumpsys telephony.registry 2>/dev/null | grep "mDataConnectionState" | head -1 | cut -d'=' -f2)
        echo -e "${BLUE}数据连接:${NC} ${data_state:-N/A}"
        
        # 运营商
        operator=$(service call iphonesubinfo 1 2>/dev/null | grep -o "'[^']*'" | head -1 | tr -d "'")
        echo -e "${BLUE}运营商:${NC} ${operator:-无法获取}"
        
        # 信号强度
        signal=$(dumpsys telephony.registry 2>/dev/null | grep "mSignalStrength" | head -1)
        echo -e "${BLUE}信号强度:${NC} ${signal:-N/A}"
        
        # IMEI
        imei=$(service call iphonesubinfo 1 2>/dev/null | grep -o "'[^']*'" | tail -1 | tr -d "'")
        echo -e "${BLUE}IMEI:${NC} ${imei:-无法获取}"
    else
        echo -e "${BLUE}移动网络信息:${NC} $(perm_warning) 需要 Root 权限"
        echo -e "${RED}  以下信息需要 Root: 网络类型、运营商、信号强度、IMEI${NC}"
    fi
    
    echo ""
}

# 网络连接测试
get_network_test() {
    print_section "【网络连接测试】"
    
    # DNS 测试(这里有bug)
    echo -e "${BLUE}DNS 测试:${NC}"
    if nslookup www.google.com >/dev/null 2>&1 || nslookup www.baidu.com >/dev/null 2>&1; then
        echo -e "${GREEN}  DNS 解析正常${NC}"
    else
        echo -e "${RED}  DNS 解析失败${NC}"
    fi
    
    # 连接测试
    echo -e "${BLUE}连接测试:${NC}"
    if ping -c 1 8.8.8.8 >/dev/null 2>&1 || ping -c 1 114.114.114.114 >/dev/null 2>&1; then
        echo -e "${GREEN}  ✓ 网络连接正常${NC}"
    else
        echo -e "${RED}  ✗ 网络连接失败${NC}"
    fi
    
    # 网关
    gateway=$(ip route 2>/dev/null | grep default | awk '{print $3}')
    echo -e "${BLUE}默认网关:${NC} ${gateway:-无法获取}"
    
    # DNS 服务器
    dns1=$(getprop net.dns1 2>/dev/null)
    dns2=$(getprop net.dns2 2>/dev/null)
    echo -e "${BLUE}DNS 服务器:${NC} ${dns1:-N/A} ${dns2:-}"
    
    # 延迟测试
    echo -e "${BLUE}延迟测试:${NC}"
    if ping -c 3 8.8.8.8 2>/dev/null | grep "avg" >/dev/null; then
        ping -c 3 8.8.8.8 2>/dev/null | grep "avg" | awk -F'/' '{print "  平均延迟: "$4" ms"}'
    else
        echo -e "${YELLOW}  无法获取延迟数据${NC}"
    fi
    
    echo ""
}

# 存储信息
get_storage_info() {
    print_section "【存储信息】"
    
    echo -e "${BLUE}内部存储:${NC}"
    df -h /data 2>/dev/null | tail -1 | awk '{print "  总计: "$2", 已用: "$3", 可用: "$4", 使用率: "$5}'
    
    # SD 卡
    if [ -d /sdcard ]; then
        echo -e "${BLUE}外部存储:${NC}"
        df -h /sdcard 2>/dev/null | tail -1 | awk '{print "  总计: "$2", 已用: "$3", 可用: "$4", 使用率: "$5}'
    else
        echo -e "${BLUE}外部存储:${NC} 未检测到"
    fi
    
    # 详细分区 (需要 Root)
    if [ $IS_ROOT -eq 1 ]; then
        echo -e "${BLUE}分区详情:${NC}"
        df -h 2>/dev/null | grep -E "^/dev" | head -10
    else
        echo -e "${BLUE}分区详情:${NC} $(perm_warning) 需要 Root"
    fi
    
    echo ""
}

# 电池信息
get_battery_info() {
    print_section "【电池信息】"
    
    battery_level=$(dumpsys battery 2>/dev/null | grep level | cut -d':' -f2 | tr -d ' ')
    battery_status=$(dumpsys battery 2>/dev/null | grep status | cut -d':' -f2 | tr -d ' ')
    battery_health=$(dumpsys battery 2>/dev/null | grep health | cut -d':' -f2 | tr -d ' ')
    battery_temp=$(dumpsys battery 2>/dev/null | grep temperature | cut -d':' -f2 | tr -d ' ')
    battery_voltage=$(dumpsys battery 2>/dev/null | grep voltage | cut -d':' -f2 | tr -d ' ')
    
    echo -e "${BLUE}电量:${NC} ${battery_level:-N/A}%"
    echo -e "${BLUE}状态:${NC} ${battery_status:-N/A}"
    echo -e "${BLUE}健康度:${NC} ${battery_health:-N/A}"
    echo -e "${BLUE}温度:${NC} ${battery_temp:-N/A}°C (实际温度需除以 10)"
    echo -e "${BLUE}电压:${NC} ${battery_voltage:-N/A} mV"
    
    # 充电状态
    if [ $IS_ROOT -eq 1 ] && [ -f /sys/class/power_supply/battery/capacity ]; then
        charge_now=$(cat /sys/class/power_supply/battery/charge_now 2>/dev/null)
        echo -e "${BLUE}当前充电:${NC} ${charge_now:-N/A} μAh"
    else
        echo -e "${BLUE}当前充电:${NC} $(perm_warning) 需要 Root"
    fi
    
    echo ""
}

# 应用信息
get_app_info() {
    print_section "【应用信息】"
    
    echo -e "${BLUE}已安装应用数:${NC} $(pm list packages 2>/dev/null | wc -l)"
    
    if [ $IS_ROOT -eq 1 ]; then
        echo -e "${BLUE}系统应用数:${NC} $(pm list packages -s 2>/dev/null | wc -l)"
        echo -e "${BLUE}第三方应用数:${NC} $(pm list packages -3 2>/dev/null | wc -l)"
        echo -e "${BLUE}禁用应用数:${NC} $(pm list packages -d 2>/dev/null | wc -l)"
    else
        echo -e "${BLUE}应用分类:${NC} $(perm_warning) 需要 Root"
    fi
    
    # 最近安装的应用
    echo -e "${BLUE}最近安装的应用 (前 5 个):${NC}"
    pm list packages 2>/dev/null | head -5 | sed 's/package://g' | while read pkg; do
        echo -e "  • $pkg"
    done
    
    echo ""
}

# 进程信息
get_process_info() {
    print_section "【进程信息】"
    
    echo -e "${BLUE}运行进程数:${NC} $(ps -A 2>/dev/null | wc -l)"
    
    # 内存占用前 5 的进程
    echo -e "${BLUE}内存占用 Top5:${NC}"
    if [ $IS_ROOT -eq 1 ]; then
        ps -A -o pid,vsz,rss,comm 2>/dev/null | sort -k3 -rn | head -6 | tail -5 | while read pid vsz rss comm; do
            echo -e "  • $comm (PID: $pid, RSS: $((rss/1024))MB)"
        done
    else
        ps 2>/dev/null | head -6 | tail -5 | while read line; do
            echo -e "  • $line"
        done
        echo -e "${YELLOW}  详细信息需要 Root 权限${NC}"
    fi
    
    # CPU 占用
    echo -e "${BLUE}CPU 核心状态:${NC}"
    for i in 0 1 2 3; do
        if [ -f /sys/devices/system/cpu/cpu$i/online ]; then
            state=$(cat /sys/devices/system/cpu/cpu$i/online 2>/dev/null)
            echo -e "  • CPU$i: $([ "$state" = "1" ] && echo "${GREEN}在线${NC}" || echo "${RED}离线${NC}")"
        fi
    done
    
    echo ""
}

# 刷新权限状态
refresh_root_status() {
    check_root
    echo -e "${GREEN}权限状态已刷新${NC}"
    show_root_status
}

# 显示全部信息
show_all() {
    show_root_status
    get_system_info
    get_hardware_info
    get_network_interfaces
    get_wifi_info
    get_mobile_info
    get_network_test
    get_storage_info
    get_battery_info
    get_app_info
    get_process_info
}

# 保存报告
save_report() {
    print_section "【保存报告】"
    
    report_file="/sdcard/Zget_report_$(date +%Y%m%d_%H%M%S).txt"
    
    echo -e "${BLUE}正在生成报告...${NC}"
    {
        echo "=========================================="
        echo "Zget 系统信息报告"
        echo "生成时间：$(date)"
        echo "设备：$(getprop ro.product.model)"
        echo "=========================================="
        echo ""
        show_root_status
        get_system_info
        get_hardware_info
        get_network_interfaces
        get_wifi_info
        get_mobile_info
        get_network_test
        get_storage_info
        get_battery_info
    } > "$report_file" 2>&1
    
    echo -e "${GREEN}报告已保存至：$report_file${NC}"
    echo ""
}

# 主函数
main() {
    check_root
    print_header
    show_root_status
    
    while true; do
        show_menu
        echo -ne "${CYAN}请输入选项 [0-12/q]: ${NC}"
        read choice
        
        case $choice in
            0)
                show_all
                ;;
            1)
                get_system_info
                ;;
            2)
                get_hardware_info
                ;;
            3)
                get_network_interfaces
                ;;
            4)
                get_wifi_info
                ;;
            5)
                get_mobile_info
                ;;
            6)
                get_network_test
                ;;
            7)
                get_storage_info
                ;;
            8)
                get_battery_info
                ;;
            9)
                get_app_info
                ;;
            10)
                get_process_info
                ;;
            11)
                show_root_status
                ;;
            12)
                refresh_root_status
                ;;
            q|Q|exit)
                echo -e "${GREEN}感谢使用 Zget！${NC}"
                exit 0
                ;;
            s|S|save)
                save_report
                ;;
            *)
                echo -e "${RED}无效选项，请重新输入${NC}"
                ;;
        esac
        
        echo -e "${YELLOW}按回车键继续...${NC}"
        read
    done
}

# 捕获退出信号
trap 'echo -e "\n${GREEN}感谢使用 Zget！${NC}"; exit 0' INT TERM

# 执行主函数
main "$@"