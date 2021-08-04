#!/bin/bash

declare -r BIN_DIR='/usr/bin'
declare -r PYTHON_REGEX="^${BIN_DIR}/python[1-9][0-9]*\.[0-9]+$"
declare -r ERROR_LOG_PATH="$0.screen.error_log"

python_prefix_length="$( wc -c <<<"${BIN_DIR}/python" )"
readonly python_prefix_length

#
# Exit handling
#
err_routine () {
  local -r script=${0-unknown}
  local -r exit_status=${1-unknown}
  local -r line_number=${2-unknown}
  local -r func_name=${3-unknown}

  # log nonzero exit status for screen process
  echo "${exit_status}" > "${ERROR_LOG_PATH}"

  1>&2 echo "${script}: Error in ${func_name} on line ${line_number}"\
    "with exit status ${exit_status}"

  exit "${exit_status}"
}

exit_routine() {
  local exit_status="${1}"

  # perform this cleanup only in main
  if [ "${STY:-null}" = 'null' ]; then
    if [ -f "${ERROR_LOG_PATH}" ]; then
      read < "${ERROR_LOG_PATH}" -r exit_status
      rm --preserve-root "${ERROR_LOG_PATH}"
      1>&2 echo "Error: Process failed with \$? = ${exit_status}."
    fi
  fi

  exit "${exit_status}"
}

trap 'err_routine $? ${LINENO} ${FUNCNAME[0]:-${0}}' ERR
trap 'exit_routine $?' EXIT

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

#
# Script Library
#
reset_line() {
  tput el1
  tput cr
}

print_command_menu() {
  printf "%s\n%s\n%s\n%s\n%s\n%s\n\n" \
    '---select an operation---' \
    '1. print python symlink priority information' \
    '2. get current python version' \
    '3. (sudo) auto configure to use newest python version' \
    '4. (sudo) manually set python version' \
    'Q/q. exit script'
}

reset_command_menu() {
  printf "\n"
  read -s -p "Press any key to continue: " -r -n1
  clear -x
  print_command_menu
}

print_alternative_info() {
  update-alternatives --query python
}

find_installed_python_versions() {
  find "${BIN_DIR}"  -regex "${PYTHON_REGEX}" \
    | cut -c "${python_prefix_length}"- | sort
}

auto_config_alternatives() {
  # Load Python executables into version manager
  sudo update-alternatives --remove-all python || echo 'No symlinks for python'
  declare -i i=0
  for vn in $(find_installed_python_versions); do
    sudo update-alternatives --install '/usr/bin/python' 'python' \
      "/usr/bin/python${vn}" "${i}"
    i=$(( i + 1 ))
  done
}

manually_set_python_version() {
  local user_input=''

  printf "[available python versions or press either b or B to go back]\n"
  find_installed_python_versions
  printf "\n"
  while read -p 'Choose a python version: ' -r user_input; do
    if [ "${user_input}" = 'b' ] || [ "${user_input}" = 'B' ]; then
      break
    elif [ -f "${BIN_DIR}/python${user_input}" ] && \
      ! [ -L "${BIN_DIR}/python${user_input}" ]; then
      sudo update-alternatives --set python "${BIN_DIR}/python${user_input}"
      break
    else
      echo 'Invaid Version'
    fi
  done
}

#
# Main
#

application_loop() {
  print_command_menu
  while read -s -r -n1 user_input; do
    case "${user_input}" in
      1)
        reset_line
        print_alternative_info
        reset_command_menu
        ;;
      2)
        reset_line
        { python --version; }
        reset_command_menu
        ;;
      3)
        reset_line
        auto_config_alternatives
        print_alternative_info
        reset_command_menu
        ;;
      4)
        reset_line
        manually_set_python_version
        print_alternative_info
        reset_command_menu
        ;;
      q|Q)
        reset_line
        printf "\nExiting script.\n"
        sleep 1
        exit 0
        ;;
      *) # unsupported flags
        reset_line
        printf "%s is not a command" "${user_input}"
        ;;
    esac
  done
}

run() {
  if [ "${STY:-null}" = "null" ]; then
    if [ "$(whoami)" != 'root' ]; then
        1>&2 echo 'Please run this script as root or using sudo'
        exit 2
    fi
    screen -S 'Manage Python Versions' -m /bin/bash "$0"
    tput cuu1
    tput el
  else
    application_loop
  fi
}

run
