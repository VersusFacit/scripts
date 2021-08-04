#!/bin/bash

set -o errexit

declare -r BL_DIR='/sys/class/backlight'
declare -r CHIP_DIR='intel_backlight'
declare -r COOL_WHITE=3500
declare -r MATCH_FLAME=1500

# adjust brightness
modulate_brightness() {

  local max_brightness_value
  local minimum_brightness_value

  local -r factor="${*}"
  declare -r filename="${BL_DIR}/${CHIP_DIR}/max_brightness"

  max_brightness_value="$(head -n 1 "${filename}")"
  minimum_brightness_value="$(bc <<<"${max_brightness_value} * ${factor}/1" )"

  sudo su -c "echo ${minimum_brightness_value} \
    > ${BL_DIR}/${CHIP_DIR}/brightness"
}

redshift_now() {
  redshift -P -O "$*" > /dev/null
}

printf "Choose a command: \n %s\n %s\n %s\n %s\n %s\n %s\n" \
  "1. Use match flame" \
  "2. Use cool white" \
  "3. Set to darkroom brightness" \
  "4. Set to usual daytime brightness" \
  "5. Set to brighter daytime brightness" \
  "   Any other key will exit"

while read -s -r -n1 user_input; do
  case "${user_input}" in
    1) redshift_now "${MATCH_FLAME}" ;;
    2) redshift_now "${COOL_WHITE}" ;;
    3) modulate_brightness 0.02;;
    4) modulate_brightness 0.05;;
    5) modulate_brightness 0.15;;
    *) exit 0
  esac
done

