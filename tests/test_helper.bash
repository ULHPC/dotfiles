#! /usr/bin/env bash
################################################################################
# test_helper.bash -
# Time-stamp: <Wed 2017-10-04 14:22:30 hcartiaux>
#
# Copyright (c) 2016 Sebastien Varrette <Sebastien.Varrette@uni.lu>
#
################################################################################

# Colors
COLOR_RED="\033[0;31m"
COLOR_BACK="\033[0m"

# Constant
DOTFILES_D=${DOTFILES_D:=$HOME/.dotfiles}
TARGET=${TARGET:=$HOME}


# See https://github.com/ztombol/bats-assert
# Note: flunk forces a test failure with an optional message
load helpers/assertions/load


print_error_and_exit() {
    echo -e  "${COLOR_RED}***ERROR***${COLOR_BACK} $*"
    exit 1
}

assert_falkor_dotfile_present() {
    local filename=$(basename $1)
    local falkor_dotfile=${DOTFILES_D}/$1
    local dotfile=${TARGET}/$filename
    if [[ ! -e "${dotfile}" ]]; then
        flunk "the dotfile '${dotfile}' does not exists"
    else
        if [[ -h "${dotfile}" ]]; then
            if [ "$(readlink $dotfile)" != "${falkor_dotfile}" ]; then
                flunk "the dotfile '$dotfile' is a symlink yet it does not point to '${falkor_dotfile}' (but to '$(readlink $dotfile)')"
            fi
        elif [[ -f "${dotfile}" ]]; then
            local checksum_src=`shasum $dotfile        | cut -d ' ' -f 1`
            local checksum_dst=`shasum $falkor_dotfile | cut -d ' ' -f 1`
            if [ "${checksum_src}" != "${checksum_dst}" ]; then
                flunk "${dotfile} is present and a file, yet its content differs from '${falkor_dotfile}'"
            fi
        fi
    fi
}

assert_falkor_dotfile_absent() {
    local filename=$(basename $1)
    local falkor_dotfile=${DOTFILES_D}/$1
    local dotfile=${TARGET}/$filename
    if [[ -e "${dotfile}" ]]; then
        if [[ -h "${dotfile}" ]]; then
            if [ "$(readlink $dotfile)" == "${falkor_dotfile}" ]; then
                flunk "the dotfile '$dotfile' is a symlink still pointing to '${falkor_dotfile}'"
            fi
        elif [[ -f "${dotfile}" ]]; then
            local checksum_src=`shasum $dotfile        | cut -d ' ' -f 1`
            local checksum_dst=`shasum $falkor_dotfile | cut -d ' ' -f 1`
            if [ "${checksum_src}" == "${checksum_dst}" ]; then
                flunk "${dotfile} is present and a file, yet its content is the same as the one of '${falkor_dotfile}'"
            fi
        fi
    fi
}
