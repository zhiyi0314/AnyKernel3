### AnyKernel3 Ramdisk Mod Script
## KernelSU with SUSFS By Numbersf
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=KernelSU by KernelSU Developers
do.devicecheck=0
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=1
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties

### AnyKernel install
## boot shell variables
block=boot
is_slot_device=auto
ramdisk_compression=auto
patch_vbmeta_flag=auto
no_magisk_check=1

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh

kernel_version=$(cat /proc/version | awk -F '-' '{print $1}' | awk '{print $3}')
case $kernel_version in
    4.1*) ksu_supported=true ;;
    5.1*) ksu_supported=true ;;
    6.1*) ksu_supported=true ;;
    6.6*) ksu_supported=true ;;
    *) ksu_supported=false ;;
esac

ui_print "  -> ksu_supported: $ksu_supported"
$ksu_supported || abort "  -> Non-GKI device, abort."

# =============
# 检测 Root 方式 (Magisk 检测)
# =============
if [ -d /data/adb/magisk ] || [ -f /sbin/.magisk ]; then
    ui_print "============="
    ui_print " 检测到 Magisk 或残留文件"
    ui_print " 在此情况下刷写内核可能会导致设备变砖"
    ui_print " 是否要继续安装？"
    ui_print " Magisk has been detected (or residual files)."
    ui_print " Flashing the kernel may brick your device"
    ui_print " Do you want to continue?"
    ui_print "-----------------"
    ui_print " 音量上键：退出脚本 (推荐)"
    ui_print " 音量下键：继续安装 (风险自负)"
    ui_print " Volume UP: Exit script (recommended)"
    ui_print " Volume DOWN: Continue installation (at your own risk)"
    ui_print "============="

    key_click=""
    while [ "$key_click" = "" ]; do
        key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
        sleep 0.2
    done

    case "$key_click" in
        "KEY_VOLUMEUP")
            ui_print " 您选择了退出脚本，已安全终止安装。"
            ui_print " You chose to exit. Installation aborted safely."
            exit 0
            ;;
        "KEY_VOLUMEDOWN")
            ui_print " 您选择了继续安装，请注意风险!"
            ui_print " You chose to continue installation. Proceed with caution!"
            ;;
        *)
            ui_print " 未知按键输入，脚本已退出。"
            ui_print " Unknown key input. Exiting script."
            exit 1
            ;;
    esac
fi

ui_print "开始安装内核..."
ui_print "Powered by GitHub@Numbersf (Aq1298 & 咿云冷雨)"

if [ -L "/dev/block/bootdevice/by-name/init_boot_a" ] || [ -L "/dev/block/by-name/init_boot_a" ]; then
    split_boot
    flash_boot
else
    dump_boot
    write_boot
fi

# =============
# SUSFS 模块安装
# =============
if [ -f "$AKHOME/ksu_module_susfs_1.5.2+_Release.zip" ]; then
    MODULE_PATH="$AKHOME/ksu_module_susfs_1.5.2+_Release.zip"
    ui_print "  -> Found SUSFS Module (Release)"
elif [ -f "$AKHOME/ksu_module_susfs_1.5.2+_CI.zip" ]; then
    MODULE_PATH="$AKHOME/ksu_module_susfs_1.5.2+_CI.zip"
    ui_print "  -> Found SUSFS Module (CI)"
else
    MODULE_PATH=""
    ui_print "  -> No SUSFS Module found.You may have selected NON mode,skipping installation."
fi

if [ -n "$MODULE_PATH" ]; then
    KSUD_PATH="/data/adb/ksud"
    ui_print "============="
    ui_print " 是否安装 SUSFS 模块？"
    ui_print " Install susfs4ksu Module?"
    ui_print "-----------------"
    ui_print " 音量上键：跳过安装"
    ui_print " 音量下键：安装模块"
    ui_print " Volume UP: Skip installation"
    ui_print " Volume DOWN: Install module"
    ui_print "============="

    key_click=""
    while [ "$key_click" = "" ]; do
        key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
        sleep 0.2
    done

    case "$key_click" in
        "KEY_VOLUMEDOWN")
            if [ -f "$KSUD_PATH" ]; then
                ui_print " 正在安装 SUSFS 模块..."
                ui_print " Installing SUSFS Module..."
                /data/adb/ksud module install "$MODULE_PATH"
                ui_print " 安装完成!"
                ui_print " Installation complete!"
            else
                ui_print " 未找到 KSUD，跳过安装。"
                ui_print " KSUD not found. Skipping installation."
            fi
            ;;
        "KEY_VOLUMEUP")
            ui_print " 已跳过 SUSFS 模块安装。"
            ui_print " Skipped SUSFS Module installation."
            ;;
        *)
            ui_print " 未知按键输入，已跳过 SUSFS 模块安装。"
            ui_print " Unknown key input. Skipped SUSFS Module installation."
            ;;
    esac
fi