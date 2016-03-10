#!/usr/bin/env bash
################################################################################
#       _   _ _     _   _ ____   ____   ____        _    __ _ _
#      | | | | |   | | | |  _ \ / ___| |  _ \  ___ | |_ / _(_) | ___  ___
#      | | | | |   | |_| | |_) | |     | | | |/ _ \| __| |_| | |/ _ \/ __|
#      | |_| | |___|  _  |  __/| |___  | |_| | (_) | |_|  _| | |  __/\__ \
#       \___/|_____|_| |_|_|    \____| |____/ \___/ \__|_| |_|_|\___||___/
#
################################################################################
# Installation script for ULHPC dotfiles within the homedir of the user running
# this script.
# Adapted from the install script set for [Falkor/dotfiles](https://github.com/Falkor/dotfiles)

#set -x # Debug

### Global variables
VERSION=0.1
COMMAND=$(basename $0)
VERBOSE=""
DEBUG=""
SIMULATION=""
OFFLINE=""
MODE=""
FORCE=""

### displayed colors
COLOR_GREEN="\033[0;32m"
COLOR_RED="\033[0;31m"
COLOR_YELLOW="\033[0;33m"
COLOR_VIOLET="\033[0;35m"
COLOR_BACK="\033[0m"

### Local variables
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES=~/.dotfiles

GIT_URL="https://github.com/ULHPC/dotfiles.git"
GIT_BRANCH="feature/falkor_import"

# What to take care of (default is empty)
WITH_BASH=""
WITH_VIM=""
WITH_GIT=""
WITH_SCREEN=""
WITH_SSH=""

#######################
### print functions ###
#######################

######
# Print information in the following form: '[$2] $1' ($2=INFO if not submitted)
# usage: info text [title]
##
info() {
    [ -z "$1" ] && print_error_and_exit "[${FUNCNAME[0]}] missing text argument"
    local text=$1
    local title=$2
    # add default title if not submitted but don't print anything
    [ -n "$text" ] && text="${title:==>} $text"
    echo -e "${COLOR_GREEN}$text${COLOR_BACK}"
}
debug()   { [ -n "$DEBUG"   ] && info "$1" "[${COLOR_YELLOW}DEBUG${COLOR_BACK}]"; }
verbose() { [ -n "$VERBOSE" ] && info "$1"; }
error()   { info "$1" "[${COLOR_RED}ERROR${COLOR_BACK}]"; }
warning() { info "$1" "[${COLOR_VIOLET}WARNING${COLOR_BACK}]"; }
print_error_and_exit() {
    local text=$1
    [ -z "$1" ] && text=" Bad format"
    error  "$text. '$COMMAND -h' for help."
    exit 1
}
print_version() {
    cat <<EOF
This is ULHPC/dotfiles/$COMMAND version "$VERSION".
Copyright (c) 2011-2016 Sebastien Varrette  (sebastien.varrette@uni.lu)
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
EOF
}
print_help() {
    less <<EOF
NAME
    $COMMAND -- install (or remove) ULHPC dotfiles in the current user's homedir

SYNOPSIS
    $COMMAND [-V | -h]
    $COMMAND [--debug] [-v] [-n] [-d DIR] [--offline] [options]
    $COMMAND --delete [-d DIR] [options]

OPTIONS
    --debug
        Debug mode. Causes $COMMAND to print debugging messages.
    -h --help
        Display a help screen and quit.
    -n --dry-run
        Simulation mode.
    -v --verbose
        Verbose mode.
    -f --force
        Force mode -- do not raise questions ;)
    -V --version
        Display the version number then quit.
    -d --dir DIR
        Set the dotfiles directory (Default: ~/.dotfiles)
    --delete --remove --uninstall
        Remove / Restore the installed components
    --offline
        Proceed in offline mode (assuming you have already cloned the repository)
    --all -a
        Install / delete ALL ULHPC dotfiles
    --bash --with-bash
        ULHPC Bourne-Again shell (Bash) configuration ~/.bashrc
    --vim --with-vim
        ULHPC VIM configuration ~/.vimrc
    --git --with-git
        ULHPC Git configuration ~/.gitconfig[.local]
    --screen --with-screen
        ULHPC GNU Screen configuration ~/.screenrc
    --ssh --with-ssh
        ULHPC ssh configuration ~/.ssh/config

EXAMPLES

    To install/remove all available dotfiles:
        $COMMAND [--delete] --all

    To install ONLY the vim/git and screen dotfiles:
        $COMMAND [--delete] --vim --git --screen

AUTHOR
    UL HPC Management Team (hpc-sysadmins@uni.lu) aka.
      S.Varrette,  H. Cartiaux, V. Plugaru and S. Diehl at the time of writting

REPORTING BUGS
    Please report bugs using the Issue Tracker of the project:
       <https://github.com/ULHPC/dotfiles/issues>

COPYRIGHT
    This is free software; see the source for copying conditions.  There is
    NO warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR
    PURPOSE.
EOF
}
#########################
### toolbox functions ###
#########################

#####
# execute a local command
# usage: execute command
###
execute() {
    [ $# -eq 0 ] && print_error_and_exit "[${FUNCNAME[0]}] missing command argument"
    debug "[${FUNCNAME[0]}] $*"
    [ -n "${SIMULATION}" ] && echo "(simulation) $*" || eval $*
    local exit_status=$?
    debug "[${FUNCNAME[0]}] exit status: $exit_status"
    return $exit_status
}

####
# ask to continue. exit 1 if the answer is no
# usage: really_continue text
##
really_continue() {
    echo -e -n "[${COLOR_VIOLET}WARNING${COLOR_BACK}] $1 Are you sure you want to continue? [Y|n] "
    read ans
    case $ans in
        n*|N*) exit 1;;
    esac
}

#####
# Check availability of binaries passed as arguments on the current system
# usage: check_bin prog1 prog2 ...
##
check_bin() {
    [ $# -eq 0 ] && print_error_and_exit "[${FUNCNAME[0]}] missing argument"
    for appl in "$@"; do
        echo -n -e "=> checking availability of the command '$appl' on your system \t"
        local tmp=$(which $appl)
        [ -z "$tmp" ] && print_error_and_exit "Please install $appl or check \$PATH." || echo -e "[${COLOR_GREEN} OK ${COLOR_BACK}]"
    done
}

####
# Add (or remove) a given link pointing to the corresponding dotfile.
# A backup of the file is performed if it previoiusly existed.
# Upon removal, the link is deleted only if it targets the expected dotfile
##
add_or_remove_link() {
    [ $# -ne 2 ] && print_error_and_exit "[${FUNCNAME[0]}] missing argument(s). Format: ${FUNCNAME[0]} <src> <dst>"
    local src=$1
    local dst=$2
    if [ "${MODE}" == "--delete" ]; then
        debug "removing dst='$dst' (if symlink pointing to src='$src' =? $(readlink $dst))"
        if [[ -h "${dst}" && "$(readlink "${dst}")" == "${src}" ]]; then
            warning "removing the symlink '$dst'"
            [ -n "${VERBOSE}" ] && really_continue
            execute "rm $dst"
            if [ -f "${dst}.bak" ]; then
                warning "restoring ${dst} from ${dst}.bak"
                execute "mv ${dst}.bak ${dst}"
            fi
        fi
    else
        [ ! -e "${src}" ] && print_error_and_exit "Unable to find the dotfile '${src}'"
        debug "attempt to add '$dst' symlink (pointing to '$src')"
        # return if the symlink already exists
        [[ -h "${dst}" && "$(readlink "${dst}")" == "${src}" ]] && return
        if [ -e "${dst}" ]; then
            warning "The file '${dst}' already exists and will be backuped (as ${dst}.bak)"
            execute "mv ${dst}{,.bak}"
        fi
        execute "ln -sf ${src} ${dst}"
    fi
}

add_or_remove_copy() {
    [ $# -ne 2 ] && print_error_and_exit "[${FUNCNAME[0]}] missing argument(s). Format: ${FUNCNAME[0]} <src> <dst>"
    local src=$1
    local dst=$2
    [ ! -f "${src}" ] && print_error_and_exit "Unable to find the dotfile '${src}'"
    if [ "${MODE}" == "--delete" ]; then
        debug "removing dst='${dst}'"
        if [[ -f $dst ]]; then
            warning "removing the file '$dst'"
            [ -n "${VERBOSE}" ] && really_continue
            execute "rm ${dst}"
            if [ -f "${dst}.bak" ]; then
                warning "restoring ${dst} from ${dst}.bak"
                execute "mv ${dst}.bak ${dst}"
            fi
        fi
    else
        debug "copying '$dst' from '$src'"
        check_bin shasum
        # return if the symlink already exists
        local checksum_src=$(shasum "${src}" | cut -d ' ' -f 1)
        local checksum_dst=$(shasum "${dst}" | cut -d ' ' -f 1)
        if [ "${checksum_src}" == "${checksum_dst}" ]; then
            echo "   - NOT copying '$dst' from '$src' since they are the same files"
            return
        fi
        if [ -f "${dst}" ]; then
            warning "The file '$dst' already exists and will be backuped (as ${dst}.bak)"
            execute "cp ${dst}{,.bak}"
        fi
        execute "cp ${src} ${dst}"
    fi
}


# courtesy of https://github.com/holman/dotfiles/blob/master/script/bootstrap
setup_gitconfig_local () {
    local gitconfig_local=${1:-"$HOME/.gitconfig.local"}
    local dotfile_gitconfig_local="${DOTFILES}/git/$(basename ${gitconfig_local})"
    if [ -f "${dotfile_gitconfig_local}" ]; then
        add_or_remove_link "${dotfile_gitconfig_local}" "${gitconfig_local}"
        return
    fi
    if [ ! -f "${gitconfig_local}" ]; then
        info "setup Local / private gitconfig '${gitconfig_local}'"
        [ -n "${SIMULATION}" ] && return
        cat > $gitconfig_local <<'EOF'
# -*- mode: gitconfig; -*-
################################################################################
#  .gitconfig.local -- Private part of the GIT configuration
#  .                   to hold username / credentials etc .
#  NOT meant to be staged for commit under github
#                _ _                   __ _         _                 _
#           __ _(_) |_ ___ ___  _ __  / _(_) __ _  | | ___   ___ __ _| |
#          / _` | | __/ __/ _ \| '_ \| |_| |/ _` | | |/ _ \ / __/ _` | |
#         | (_| | | || (_| (_) | | | |  _| | (_| |_| | (_) | (_| (_| | |
#        (_)__, |_|\__\___\___/|_| |_|_| |_|\__, (_)_|\___/ \___\__,_|_|
#          |___/                            |___/
#
# See also: http://github.com/ULHPC/dotfiles
################################################################################
EOF

        local git_credential='cache'
        local git_authorname=
        local git_email=
        if [ "$(uname -s)" == "Darwin" ]; then
            git_authorname=$(dscl . -read /Users/$(whoami) RealName | tail -n1)
            git_credential='osxkeychain'
        elif [ "$(uname -s)" == "Linux" ]; then
            git_authorname=$(getent passwd $(whoami) | cut -d ':' -f 5 | cut -d ',' -f 1)
        fi
        [ -n "${GIT_AUTHOR_NAME}" ] && git_authorname="${GIT_AUTHOR_NAME}"
        [ -n "${GIT_AUTHOR_EMAIL}"] && git_email="${GIT_AUTHOR_EMAIL}"
        if [ -z "${git_authorname}" ]; then
            echo -e -n  "[${COLOR_VIOLET}WARNING${COLOR_BACK}] Enter you Git author name:"
            read -e git_authorname
        fi
        if [ -z "${git_email}" ]; then
            echo -e -n  "[${COLOR_VIOLET}WARNING${COLOR_BACK}] Enter you Git author email:"
            read -e git_email
        fi
        cat >> $gitconfig_local <<EOF
[user]
    name   = $git_authorname
    email  = $git_email
    helper = $git_credential
EOF
    fi
}


################################################################################
################################################################################
# Let's go

ACTION="install"
# Check for options
while [ $# -ge 1 ]; do
    case $1 in
        -h | --help)    print_help;        exit 0;;
        -V | --version) print_version;     exit 0;;
        --debug)        DEBUG="--debug";
                        VERBOSE="--verbose";;
        -v | --verbose) VERBOSE="--verbose";;
        -f | --force)   FORCE="--force";;
        -n | --dry-run) SIMULATION="--dry-run";;
        --offline)      OFFLINE="--offline";;
        --delete | --remove | --uninstall)
            ACTION="uninstall"; OFFLINE="--offline"; MODE="--delete";;
        -d | --dir | --dotfiles)
            shift;       DOTFILES=$1;;
        --with-bash  | --bash)   WITH_BASH='--with-bash';;
        --with-vim   | --vim)    WITH_VIM='--with-vim';;
        --with-git   | --git)    WITH_GIT='--with-git';;
        --with-screen| --screen) WITH_SCREEN='--with-screen';;
        --with-ssh   | --ssh)    WITH_SSH='--with-ssh';;
        -a | --all)
            WITH_BASH='--with-bash';
            WITH_VIM='--with-vim';
            WITH_GIT='--with-git';
            WITH_SCREEN='--with-screen';
            WITH_SSH='--with-ssh';;
    esac
    shift
done
[ -z "${DOTFILES}" ] && print_error_and_exit "Wrong dotfiles directory (empty)"
echo "${DOTFILES}" | grep  '^\/' > /dev/null
greprc=$?
if [ $greprc -ne 0 ]; then
    warning "Assume dotfiles directory '${DOTFILES}' is relative to the home directory"
    DOTFILES="$HOME/${DOTFILES}"
fi
info "About to ${ACTION} ULHPC dotfiles from ${DOTFILES}"
[ -z "${FORCE}" ] && really_continue

if [ "${SCRIPTDIR}" != "${DOTFILES}" ]; then
    if [ -d "${SCRIPTDIR}/.git" -a ! -e "${DOTFILES}" ]; then
        # We are (hopefully) in a clone of the ULHPC dotfile repository.
        # Make $DOTFILES be a symlink to this clone.
        info "make '${DOTFILES}' a symlink to ${SCRIPTDIR}"
        execute "ln -s ${SCRIPTDIR} ${DOTFILES}"
    fi
fi

# Update the repository if already present
[[ -z "${OFFLINE}" && -d "${DOTFILES}" ]]   && execute "( cd ${DOTFILES} ; git pull )"
# OR clone it there
[[ ! -d "${DOTFILES}" ]] && execute "git clone -b ${GIT_BRANCH} -q --recursive --depth 1 ${GIT_URL} ${DOTFILES}"

cd ~

if [ -z "${WITH_BASH}${WITH_VIM}${WITH_GIT}${WITH_SCREEN}${WITH_SSH}" ]; then
    warning " "
    warning "By default, this installer does nothing except updating ${DOTFILES}."
    warning "Use '$0 --all' to install all available configs. OR use a discrete set of options."
    warning "Ex: '$0 $MODE --with'"
    warning " "
    exit 0
fi


## Bash
if [ -n "${WITH_BASH}" ]; then
    info "${ACTION} ULHPC Bourne-Again shell (Bash) configuration ~/.bashrc ~/.inputrc ~/.bash_profile ~/.profile ~/.bash_logout"
    add_or_remove_link "${DOTFILES}/bash/.bashrc"       ~/.bashrc
    add_or_remove_link "${DOTFILES}/bash/.inputrc"      ~/.inputrc
    add_or_remove_link "${DOTFILES}/bash/.bash_profile" ~/.bash_profile
    add_or_remove_link "${DOTFILES}/bash/.profile"      ~/.profile
    add_or_remove_link "${DOTFILES}/bash/.bash_logout"  ~/.bash_logout
fi

## VI iMproved ([m]Vim)
if [ -n "${WITH_VIM}" ]; then
    info "${ACTION} ULHPC VIM configuration ~/.vimrc"
    add_or_remove_link "${DOTFILES}/vim/.vimrc" ~/.vimrc
    if  [ "${MODE}" != "--delete" ]; then
        warning "Run vim afterwards to download the expected package (using NeoBundle)"
        if [ "$(uname -s)" == "Linux" ]; then
            warning "After Neobundle installation and vim relaunch, you might encounter the bug #156"
            warning "        https://github.com/avelino/vim-bootstrap/issues/156"
        fi
    fi
fi

## Git
if [ -n "${WITH_GIT}" ]; then
    info "${ACTION} ULHPC Git configuration ~/.gitconfig[.local]"
    add_or_remove_link "${DOTFILES}/git/.gitconfig" ~/.gitconfig
    if [ "${MODE}" != "--delete" ]; then
        setup_gitconfig_local  ~/.gitconfig.local
    else
        add_or_remove_copy ' ' ~/.gitconfig.local
    fi
fi

## GNU Screen
if [ -n "${WITH_SCREEN}" ]; then
    info "${ACTION} ULHPC GNU Screen configuration ~/.screenrc"
    add_or_remove_link "${DOTFILES}/screen/.screenrc" ~/.screenrc
fi

## SSH
if [ -n "${WITH_SSH}" ]; then
    info "${ACTION} ULHPC SSH configuration ~/.ssh/config"
    mkdir -p ~/.ssh
    add_or_remove_link "${DOTFILES}/ssh/config" ~/.ssh/config
    if [ "${MODE}" != "--delete" ]; then
        rmdir ~/.ssh
    fi
fi

