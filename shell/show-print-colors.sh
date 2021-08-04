#!/bin/bash

set -e

newline() {
  printf "\n"
}

#
# Print 256 Colors in Terminal in Blocks
#

readonly COLS="6"
readonly NUM_IN_BLOCK="36"

indent() {
  tput sgr0
  printf "   | "
}

colorize-num() {
  printf "\x1b[38;5;${1}m%3d " "$1"
}

# Starting at $1, print a run of $2 colours
colorize() {
  local -r first_number="${1}"
  local -r last_number="${2}"
  local -r ITEMS_PER_LINE="${3:-16}"

  local number_of_items_printed=0

  indent

  col="${first_number}"
  while [ "$col" -le "${last_number}" ]; do
    colorize-num "$col"

    # Prints newline after ITEMS_PER_LINE items are in single row
    number_of_items_printed="$(( number_of_items_printed + 1 ))"
    if [ "$number_of_items_printed" = "$ITEMS_PER_LINE" ]; then
      newline
      if [ "$col" -lt "$last_number" ]; then
        indent
      fi
      number_of_items_printed=0
    fi

    col="$(( col + 1 ))"
  done
}

# Print blocks of colours
log-color-blocks() {

  local -r first_color="$1" last_color="$2"

  #  -- Helper --
  # log a single color-block
  log-color-block() {
    iterator=$1
      offset=$2

    while [ "${iterator}" -lt "${offset}" ]; do
      colorize "${iterator}" "$(( iterator + COLS - 1))"
      newline

      iterator="$(( iterator + 6 ))"
    done
    newline
  }

  current_color="${first_color}"
  while [ "$current_color" -le "${last_color}" ]; do
    log-color-block "$current_color" "$(( NUM_IN_BLOCK + current_color ))"

    current_color="$(( current_color + NUM_IN_BLOCK ))"
  done
}

##
## Top-Level Functions
##

construct-header() {
  newline
  echo '    --- Printing 256 ANSI Terminal Colors ---'
  newline
}

first-16-colors() {
  colorize 0 15 8
  newline
}

colors-above-16() {
  log-color-blocks 16 231
  newline
}

greyscale() {
  colorize 232 255 12
  newline
}

##
## Execution
##

construct-header
first-16-colors
colors-above-16
greyscale

