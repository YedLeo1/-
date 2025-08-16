Dirs="/vendor /odm /system/vendor /system/system_ext/"
mod_dir_a="/data/adb/modules/Caelifall_SensorDecoy"
mod_dir_b="/data/adb/modules_updata/Caelifall_SensorDecoy"
TARGET_DIRS="/data/user/0/com.tencent.mobileqq/shared_prefs/ /data/user/999/com.tencent.mobileqq/shared_prefs/ /data/user/0/com.tencent.tim/shared_prefs/"
GROUP_PATTERNS="743741728|418752960|803527649|642918370|1012713006|351704986|925841736|760312594|482956071|127259333|593160278|814732956|276508193|941285360|101466315|608374251|459376779|329615807|785409321|1056439857|562198437|907481326|183256749|610527834|874521093|201937584|546378901|390845127|712590638|481062957|935728410|624915837|170834295|859603172|243179586|506847921|378295140|691507328|425869713|973016482|152486039|830957214|267138945|548902173|301674859|729581604|461320798|984052167|136748250|852917463|270385914|594162870|317804925|620593418|479135026|908276145|145398267|860749153|239865714|517403298|382956107|704182956|459376779|961205834|185032476|834719602|271584093|506927148|398460517|720519364|413695280|987250631|154039826|867312954|240958173|571863042|309245861|628571490|473096285|915427306|138605729|852974136|264189053|507362948|391845620|725693014|480172596|936284105|172856403|854903627|296175840|510342967|378905142|602187593|425718690|953046712"
 
VERIFY_GROUP_CHAT() {
  local verified=false
  for dir in $TARGET_DIRS; do
    if [ -d "$dir" ] && grep -Eq "$GROUP_PATTERNS" "$dir"/* 2>/dev/null; then
      echo "  ✓ 捐赠群验证成功 模块继续安装"
      verified=true
      break
    fi
  done
 
  if ! $verified; then
    echo "  ✕ 捐赠群验证失败 请留意提示"
    echo "①若未入捐赠群 联系QQ3423852590 捐赠5R即可入群(包更新)"
    echo "②若已进捐赠群 请在当前设备登录QQ后并在群内发言(TIM也可)"  
    rm -rf "$mod_dir_a" 2>/dev/null 
    rm -rf "$mod_dir_b" 2>/dev/null 
    exit 1
  fi
}

GET_PHONE_INFO_AND_CHECK_EXIT() {
    os_display_version_part=$(getprop ro.build.display.id | cut -d '.' -f 4 | cut -d '(' -f 1)
    device_manufacturer_name=$(getprop ro.product.odm.manufacturer)
    system_on_chip_model=$(getprop ro.soc.model | tr 'a-z' 'A-Z')
    device_market_name=$(getprop ro.vendor.oplus.market.name)
    android_os_version_number=$(getprop ro.build.version.release)
    android_sdk_version=$(getprop ro.build.version.sdk)

    kernel_version=$(getprop ro.kernel.version)
    if [ -z "$kernel_version" ]; then
        kernel_version=$(getprop ro.build.kernel.id)
    fi

    security_patch_level=$(getprop ro.build.version.security_patch)
    product_model=$(getprop ro.product.model)
    baseband_version=$(getprop gsm.version.baseband | cut -d ',' -f 1)
    serial_number=$(getprop ro.boot.serialno)
    screen_density_dpi=$(getprop ro.sf.lcd_density)

    custom_os_name="Android"
    case "$device_manufacturer_name" in
        "OnePlus" | "OPPO")
            custom_os_name="ColorOS"
            ;;
        "realme")
            custom_os_name="Realme UI"
            ;;
        *)
            ;;
    esac
    echo "-------------------------------------------" && sleep 0.1
    echo "制造商: $device_manufacturer_name" && sleep 0.1
    echo "型号: $device_market_name ($product_model)" && sleep 0.1
    echo "处理器: $system_on_chip_model" && sleep 0.1
    echo "系统: $custom_os_name ($os_display_version_part)" && sleep 0.1
    echo "安卓版本: $android_os_version_number" && sleep 0.1
    echo "SDK版本: $android_sdk_version" && sleep 0.1
    echo "内核: $kernel_version" && sleep 0.1
    echo "安全补丁: $security_patch_level" && sleep 0.1
    echo "基带: $baseband_version" && sleep 0.1
    echo "序列号: $serial_number" && sleep 0.1
    echo "屏幕DPI: $screen_density_dpi" && sleep 0.1
    echo "-------------------------------------------" && sleep 0.1

    VERIFY_GROUP_CHAT 

    if [ -f "/data/adb/modules/Caelifall_SensorDecoy/module.prop" ] && [ "$(grep "versioncode=" /data/adb/modules/Caelifall_SensorDecoy/module.prop | cut -d'=' -f2)" != "666666" ]; then
  echo "支持覆盖安装之后模块故障率上升，多数版本更新我会取消覆盖安装，在少部分之间支持，请务必正常卸载旧版后安装。理解万岁"
  exit 1
    fi

    if echo "$system_on_chip_model" | grep -qi "MT"; then
        echo "当前为天玑机型…"
    fi

    if (( $(echo "$android_os_version_number < 14" | bc -l) )); then
        echo "安卓版本过低 请更新为Android 14+"
        exit 1
    fi

    case "$device_manufacturer_name" in
        "OPPO" | "OnePlus" | "realme")
            ;;
        *)
            echo "检测到当前机型非欧真加 其他品牌设备使用此模块可能效果不佳"
            exit 1
            ;;
    esac

    CONFLICT_CHECK
}

CONFLICT_CHECK() {
for mod_path in /data/adb/modules/*; do
  prop_file="$mod_path/module.prop"
  if [ -f "$prop_file" ]; then
    mod_name=$(grep "^name=" "$prop_file" | cut -d'=' -f2-)

    if grep -q "墓碑" "$prop_file"; then
      echo "存在冲突模块:$mod_name"
      echo "满血核心已自带墓碑 若你使用其他墓碑，不打开满血核心的墓碑开关即可"
    fi

    if grep -qE "去除温控|Extreme GT|解除温控限制|rkk_karakuchi|Moka|触控|采样率|强制快充|充电守护" "$prop_file"; then
      if ! echo "$mod_name" | grep -q "满血核心"; then
        echo "存在冲突模块:$mod_name"
        echo "请将其卸载并重启"
        exit 1
      fi
    fi
  fi
done

}

SHIELD_TEMP_HORAE() {
    Device_market_name=$(getprop ro.vendor.oplus.market.name)
    cleaned_name=$(echo "$Device_market_name" | tr -d ' ' | tr '[:upper:]' '[:lower:]')
    if ! echo "$cleaned_name" | grep -Eq "真我gt7pro|真我gt5pro"; then
    files="horae*.conf"
    for dir in $Dirs; do
        for file in $files; do
            find "$dir" -type f -name "$file" | while read -r found_file; do
                target_dir="$MODPATH$(dirname "$found_file")"
                mkdir -p "$target_dir"
                touch "$target_dir/$(basename "$found_file")"
                echo "  ✓ 已处理: $(basename "$found_file")"
            done
        done
    done
    fi
}

PROCESS_ALL_CONFIGS() {
  for dir in $Dirs; do

    find "$dir" -name "sys_high_temp_protect_*.xml" | while read -r file; do
      echo "  ✓ 已处理: $(basename "$file")"
      mkdir -p "$(dirname "$MODPATH$file")"
      sed -E 's/([>])(3[5-9][0-9]|[4-6][0-9]{2}|7[0-4][0-9]|750)([<])/\10\3/g; s/true/false/g' "$file" > "$MODPATH$file"
    done

    find "$dir" -name "sys_thermal_control_config*.xml" | while read -r file; do
      echo "  ✓ 已处理: $(basename "$file")"
      mkdir -p "$(dirname "$MODPATH$file")"
      sed -E \
        -e 's/(<feature_enable_item|<feature_safety_test_enable_item|<aging_thermal_control_enable_item).*\/>/\1 booleanVal="false" \/>/g' \
        -e 's/(<aging_cpu_level_item|<high_temp_safety_level_item|<game_high_perf_mode_item|<normal_mode_item|<ota_mode_item|<racing_mode_item).*\/>/\1 intVal="-1" \/>/g' \
        -e '/<gear_config|cpu=|fps=|<scene_|<\/scene_|<category_|<\/category_|<subitem|<level|\./d' \
        "$file" | tr -s '\n' > "$MODPATH$file"
    done

    find "$dir" -name "thermallevel_to_fps.xml" | while read -r file; do
      echo "  ✓ 已处理: $(basename "$file")"
      mkdir -p "$(dirname "$MODPATH$file")"
      cat "$file" | sed "s/fps=\".*\"/fps=\"144\"/" > "$MODPATH$file"
    done

    find "$dir" -name "sys_thermal_config.xml" | while read -r file; do
      echo "  ✓ 已处理: $(basename "$file")"
      mkdir -p "$(dirname "$MODPATH$file")"
      sed -E \
        -e '/<version>2018101710<\/version>/!s/>1</>0</g' \
        -e 's/([>])(3[5-9][0-9]|4[0-9]{2}|5[0-4][0-9]|550)([<])/\10\3/g' \
        -e '/com\./d' \
        "$file" > "$MODPATH$file"
      done

    find "$dir" -name "devices_config.json" | while read -r file; do
      echo "  ✓ 已处理: $(basename "$file")"
      mkdir -p "$(dirname "$MODPATH$file")"
      sed -E '
      /"high.capacity.threshold": 100/b; 
      s/"high.capacity.threshold": ([0-9]{1,2})/"high.capacity.threshold": 99/g; 
      s/"battery.temperate.range": "\[150,450\]"/"battery.temperate.range": "\[150,550\]"/g; 
      s/"high.capacity.battery.temperate.range": "\[150,450\]"/"high.capacity.battery.temperate.range": "\[150,550\]"/g
    ' "$file" > "$MODPATH$file"
      done

    find "$dir" -name "QEGA_Config.txt" | while read -r file; do
      echo "  ✓ 已处理: $(basename "$file")"
      mkdir -p "$(dirname "$MODPATH$file")"
      sed \
        -e 's/SkinTemperatureNode:   xo-therm/SkinTemperatureNode:   battery/' \
        -e '/^100001/s/100001    hok         48000          1200        1000/180001    hok         55000          2000        1000/' \
        -e '/^0         adaptive/s/50000/55000/' \
        "$file" > "$MODPATH$file"
    done

    find "$dir" -name "charging_*.txt" | while read -r file; do
      echo "  ✓ 已处理: $(basename "$file")"
      mkdir -p "$(dirname "$MODPATH$file")"
      temp_file="${MODPATH}${file}.tmp"
      cat "$file" | while read -r line; do
        if echo "$line" | grep -qE '^[0-9]+,[0-9]+,[0-9]+$'; then
          first_num=$(echo "$line" | cut -d',' -f1)
          rest_of_line=$(echo "$line" | cut -d',' -f2-)
          new_first_num=$((first_num + 120))
          echo "${new_first_num},${rest_of_line}" >> "$temp_file"
        else
          echo "$line" >> "$temp_file"
        fi
      done
      mv "$temp_file" "$MODPATH$file"
    done

  done
}

FOLLOW_COMPLETE() {
    echo " "
    echo "ʚ捐赠特别版ɞ"
    echo " "
    echo "◨使用须知◧"
    echo "如果覆盖安装后模块效果不理想 请务必尝试卸载后重刷"
    echo "作者只维护最新版本 如果旧版本出现问题请先升级新版"
    echo " "
    echo "点个关注吗?"
    echo "音量[+]现在去   音量[-]点过了"
    
    local key_click=""
    while [ -z "$key_click" ]; do
        key_click=$(getevent -qlc 1 | awk '/KEY_VOLUMEUP|KEY_VOLUMEDOWN/ {print $3}')
        sleep 0.5
    done

    if [ "$key_click" = "KEY_VOLUMEUP" ]; then
        am start -a android.intent.action.VIEW -d "http://www.coolapk.com/u/24621888"
    fi

    echo " "
    local Model=$(getprop ro.vendor.oplus.market.name)
    sed -i "s/^description=.*/description=[未启用]请重启设备… $Model $(date +"%H:%M:%S")/" "$MODPATH/module.prop"
    echo "安装完成"
}

GET_PHONE_INFO_AND_CHECK_EXIT
PROCESS_ALL_CONFIGS                       
SHIELD_TEMP_HORAE   
FOLLOW_COMPLETE
