#! /bin/bash
################################################################################
#  .bashrc -- ULHPC Bourne-Again shell (aka bash) configuration
#             see https://github.com/ULHPC/dotfiles
#
#  Copyright (c) 2010 Sebastien Varrette <Sebastien.Varrette@uni.lu>
#                https://varrette.gforge.uni.lu
#  Copyright (c) 2013 Hyacinthe Cartiaux <Hyacinthe.Cartiaux@uni.lu>
#                   _               _
#                  | |__   __ _ ___| |__  _ __ ___
#                  | '_ \ / _` / __| '_ \| '__/ __|
#               _  | |_) | (_| \__ \ | | | | | (__
#              (_) |_.__/ \__,_|___/_| |_|_|  \___|
#
################################################################################
# This file is NOT part of GNU bash
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.
################################################################################
# Resources:
#  - https://github.com/hcartiaux/dotfiles
#  - https://github.com/Falkor/dotfiles/blob/master/bash/.bashrc
#  - http://bitbucket.org/dmpayton/dotfiles/src/tip/.bashrc
#  - https://github.com/rtomayko/dotfiles/blob/rtomayko/.bashrc

# Basic variables
: ${HOME=~}
: ${LOGNAME=$(id -un)}
: ${UNAME=$(uname)}

# complete hostnames from this file
: ${HOSTFILE=~/.ssh/known_hosts}

# readline config
: ${INPUTRC=~/.inputrc}

# Get rid of mail notification
unset MAILCHECK

# Define the boolean IS_ADMIN
echo "root localadmin" | grep -F -q -w "$LOGNAME"
(( IS_ADMIN = $? == 0 ? 1 : 0))


# ----------------------------------------------------------------------
#  SHELL OPTIONS
# ----------------------------------------------------------------------

# bring in system bashrc
test -r /etc/bashrc &&
    . /etc/bashrc

# bring in git prompt
test -e ~/.git-prompt.sh &&
. ~/.git-prompt.sh

# shell opts. see bash(1) for details
shopt -s cdspell                 >/dev/null 2>&1  # correct minor errors in the spelling
                                                  # of a directory in a cd command
shopt -s extglob                 >/dev/null 2>&1  # extended pattern matching
shopt -s hostcomplete            >/dev/null 2>&1  # perform hostname completion
                                                  # on '@'
shopt -u mailwarn                >/dev/null 2>&1

# default umask
umask 0022

# ----------------------------------------------------------------------
# LS AND DIRCOLORS
# ----------------------------------------------------------------------
# Colored output from ls is nice
export CLICOLOR=1

# we always pass these to ls(1)
LS_COMMON="-hB"

# if the dircolors utility is available, set that up to
dircolors="$(type -P gdircolors dircolors | head -1)"
test -n "$dircolors" && {
    COLORS=/etc/DIR_COLORS
    test -e "/etc/DIR_COLORS.$TERM"   && COLORS="/etc/DIR_COLORS.$TERM"
    test -e "$HOME/.dircolors"        && COLORS="$HOME/.dircolors"
    test ! -e "$COLORS"               && COLORS=
    eval "$($dircolors --sh $COLORS)"
}
unset dircolors

if [ "$UNAME" = Darwin ]; then
    # check if you're using gnu core-utils then use --color
    test "$(which ls)" = "/opt/local/bin/ls" && {
        LS_COMMON="$LS_COMMON --color"
    } || {
        LS_COMMON="$LS_COMMON -G"
    }
elif [ "$UNAME" = Linux ]; then
    LS_COMMON="$LS_COMMON --color"
fi

# setup the main ls alias if we've established common args
test -n "$LS_COMMON" &&
    alias ls="command ls $LS_COMMON"

# these use the ls aliases above
alias ll="ls -l"
alias la="ll -a"
alias l.="ls -d .*"

# ----------------------------------------------------------------------
#  ALIASES
# ----------------------------------------------------------------------
# Mandatory aliases to confirm destructive operations
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -i'

alias ..='cd ..'

alias grep='grep --color=auto'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# ----------------------------------------------------------------------
# ENVIRONMENT CONFIGURATION
# ----------------------------------------------------------------------
# detect interactive shell
case "$-" in
    *i*) INTERACTIVE=yes ;;
    *)   unset INTERACTIVE ;;
esac

# detect login shell
case "$0" in
    -*) LOGIN=yes ;;
    *)  unset LOGIN ;;
esac

# enable en_US locale w/ UTF-8 encodings if not already configured
# : ${LANG:="en_US.UTF-8"}
# : ${LANGUAGE:="en"}
# : ${LC_CTYPE:="en_US.UTF-8"}
# : ${LC_ALL:="en_US.UTF-8"}
# export LANG LANGUAGE LC_CTYPE LC_ALL

# ----------------------------------------------------------------------
# PATH
# ----------------------------------------------------------------------
# we want the various sbins on the path along with /usr/local/bin
PATH="$PATH:/usr/local/sbin:/usr/sbin:/sbin"
PATH="/usr/local/bin:$PATH"

# put ~/bin on PATH if it exists
if [ -d "$HOME/bin" ]; then
    PATH="$PATH:$HOME/bin"
fi
# put ~/.local/bin on PATH if it exists
if [ -d "$HOME/.local/bin" ]; then
    PATH="$PATH:$HOME/.local/bin"
fi
MANPATH="/usr/share/man:/usr/local/share/man:$MANPATH"

# === Programming stuff ===
# pkg-config settings
# PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH

# C/C++ include
C_INCLUDE_PATH=/usr/local/include
CPLUS_INCLUDE_PATH=${C_INCLUDE_PATH}
# LIBRARY_PATH=/usr/lib:/usr/local/lib
# DYLD_FALLBACK_LIBRARY_PATH=${LIBRARY_PATH}

# GPFS admin commands
if (($IS_ADMIN)) && [ -d /usr/lpp/mmfs/bin ] ; then
    PATH="$PATH:/usr/lpp/mmfs/bin/"
fi

# ----------------------------------------------------------------------
# PAGER / EDITOR
# ----------------------------------------------------------------------

# Default editor
test -n "$(command -v vim)" && EDITOR=vim || EDITOR=nano
export EDITOR

# Default pager ('less' is so much better than 'more'...)
if test -n "$(command -v less)" ; then
    #PAGER="less -FirSwX"
    PAGER=less
    MANPAGER="less -FiRswX"
else
    PAGER=more
    MANPAGER="$PAGER"
fi
export PAGER MANPAGER

# ----------------------------------------------------------------------
# BASH COMPLETION
# ----------------------------------------------------------------------

bash=${BASH_VERSION%.*}; bmajor=${bash%.*};
test -n "$PS1" && test "$bmajor" -gt 1 && {
        # search for a bash_completion file to source
        for f in /usr/local/etc/bash_completion \
                 /usr/share/bash-completion/bash_completion \
                 /opt/local/etc/bash_completion \
                 /etc/bash_completion
        do
            test -f $f && . $f && break
        done
}
unset bash bmajor

# ----------------------------------------------------------------------
# OAR Batch scheduler
# ----------------------------------------------------------------------
# Resources:
# - http://wiki-oar.imag.fr/index.php/Customization_tips
# - http://wiki-oar.imag.fr/index.php/Oarsh_and_bash_completion

# oarsh completion
function _oarsh_complete_()
{
  local word=${COMP_WORDS[COMP_CWORD]}
  local list
  list=$(uniq "$OAR_NODEFILE" | tr '\n' ' ')
  COMPREPLY=($(compgen -W "$list" -- "${word}"))
}
complete -F _oarsh_complete_ oarsh

# Job + Remaining time
__oar_ps1_remaining_time(){
  if [ -n "$OAR_JOB_WALLTIME_SECONDS" -a -n "$OAR_NODE_FILE" -a -r "$OAR_NODE_FILE" ]; then
    DATE_NOW=$(date +%s)
    DATE_JOB_START=$(stat -c %Y "$OAR_NODE_FILE")
    DATE_TMP=$OAR_JOB_WALLTIME_SECONDS
    ((DATE_TMP = (DATE_TMP - DATE_NOW + DATE_JOB_START) / 60))
    echo -n "[OAR$OAR_JOB_ID->$DATE_TMP]"
  fi
}

# OAR motd

test -n "$INTERACTIVE" && test -n "$OAR_NODE_FILE" && (
  echo "[OAR] OAR_JOB_ID=$OAR_JOB_ID"
  echo "[OAR] Your nodes are:"
  sort "$OAR_NODE_FILE" | uniq -c | awk '{printf("      %s*%d\n",$2,$1)}END{printf("\n")}' | sed -e 's/,$//'
)


# ----------------------------------------------------------------------
# BASH HISTORY
# ----------------------------------------------------------------------

# Increase the history size
HISTSIZE=10000
HISTFILESIZE=20000

# Lines which begin with a space character are not saved in the history list.
HISTCONTROL=ignorespace

# Add date and time to the history
HISTTIMEFORMAT="[%d/%m/%Y %H:%M:%S] "

# ----------------------------------------------------------------------
# VERSION CONTROL SYSTEM - CVS, SVN and GIT
# ----------------------------------------------------------------------
# === CVS ===
export CVS_RSH='ssh'

# === SVN ===
export SVN_EDITOR=$EDITOR


## display the current subversion revision (to be used later in the prompt)
__svn_ps1() {
  (
    local svnversion
    svnversion=$(svnversion | sed -e "s/[:M]//g")
    # Continue if $svnversion is numerical
    let $svnversion
    if [[ "$?" -eq "0" ]]
    then
        printf " (svn:%s)" "$(svnversion)"
    fi
  ) 2>/dev/null
}

# === GIT ===
# render __git_ps1 even better so as to show activity in a git repository
#
# see https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh for
# configuration info of the GIT_PS1* variables

# fix error with __git_ps1 in screen
if [[ -f /etc/bash_completion.d/git ]] ; then
  source /etc/bash_completion.d/git
fi

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1


# ----------------------------------------------------------------------
# PROMPT
# ----------------------------------------------------------------------

# Define some colors to use in the prompt
RESET_COLOR="\[\e[0m\]"
BOLD_COLOR="\[\e[1m\]"
# B&W
WHITE="\[\e[0;37m\]"
# RGB
RED="\[\e[0;31m\]"
GREEN="\[\e[0;32m\]"
BLUE="\[\e[34;1m\]"
# other
YELLOW="\[\e[0;33m\]"
LIGHT_CYAN="\[\e[36;1m\]"
CYAN_UNDERLINE="\[\e[4;36m\]"

# Configure user color and prompt type depending on whoami
if [ "$LOGNAME" = "root" ]; then
    COLOR_USER="${RED}"
    P="#"
else
    COLOR_USER="${WHITE}"
    P=""
fi

# Configure a set of useful variables for the prompt
if [[ -e /proc/sys/kernel/hostname ]] ; then
    DOMAIN=$(cat /proc/sys/kernel/hostname | cut -d '.' -f 2)
elif [[ "$(echo $UNAME | grep -c -i -e '^.*bsd$')" == "1" ]] ; then
    DOMAIN=$(hostname | cut -d '.' -f 2)
else
    DOMAIN=$(hostname -f | cut -d '.' -f 2)
fi

# get virtualization information
XENTYPE=""
if [ -f "/sys/hypervisor/uuid" ]; then
    if [ "$(</sys/hypervisor/uuid)" == "00000000-0000-0000-0000-000000000000" ]; then
        XENTYPE=",Dom0"
    else
        XENTYPE=",DomU"
    fi
fi
# Test the PS1_EXTRA variable
if [ -z "${PS1_EXTRA}" -a -f "/proc/cmdline" ]; then
    # Here PS1_EXTRA is not set and/or empty, check additionally if it has not
    # been set via kernel comment
    kernel_ps1_extra="$(grep PS1_EXTRA /proc/cmdline)"
    if [ -n "${kernel_ps1_extra}" ]; then
        PS1_EXTRA=$( sed -e "s/.*PS1_EXTRA=\"\?\([^ ^\t^\"]\+\)\"\?.*/\1/g" /proc/cmdline )
    fi
fi
PS1_EXTRAINFO="${BOLD_COLOR}${DOMAIN}${XENTYPE}${RESET_COLOR}"
if [ -n "${PS1_EXTRA}" ]; then
    PS1_EXTRAINFO="${PS1_EXTRAINFO},${YELLOW}${PS1_EXTRA}${RESET_COLOR}"
fi


# This function is called from a subshell in $PS1, to provide the colorized
# exit status of the last run command.
# Exit status 130 is also considered as good as it corresponds to a CTRL-D
__colorized_exit_status() {
    printf -- "\$(status=\$? ; if [[ \$status = 0 || \$status = 130  ]]; then \
                                echo -e '\[\e[01;32m\]'\$status;              \
                              else                                            \
                                echo -e '\[\e[01;31m\]'\$status; fi)"
}

###########
# my prompt; the format is as follows:
#
#    [hh:mm:ss]:$?: username@hostname(domain[,xentype][,extrainfo]) workingdir(svn/git status)$>
#    `--------'  ^  `------' `------'         `--------'`--------------'
#       cyan     |  root:red   cyan              light     green
#                |           underline            blue   (absent if not relevant)
#           exit code of
#        the previous command
#
# The git/svn status part is quite interesting: if you are in a directory under
# version control, you have the following information in the prompt:
#   - under GIT: current branch name, followed by a '*' if the repository has
#                uncommitted changes, followed by a '+' if some elements were
#                'git add'ed but not commited.
#   - under SVN: show (svn:XX[M]) where XX is the current revision number,
#                followed by 'M' if the repository has uncommitted changes
#
# `domain` reflect the current domain of the machine that run the prompt
# (guessed from hostname -f)
# `xentype` is DOM0 or domU depending if the machine is a Xen dom0 or domU
# Finally, is the environment variable PS1_EXTRA is set (or passed to the
# kernel), then its content is displayed here.
#
# This prompt is perfect for terminal with black background, in my case the
# Vizor color set (see http://visor.binaryage.com/) or iTerm2
__set_my_prompt() {
    PS1="$(__colorized_exit_status) ${LIGHT_CYAN}[\t]${RESET_COLOR} ${COLOR_USER}\u${RESET_COLOR}@${CYAN_UNDERLINE}\h${RESET_COLOR}(${PS1_EXTRAINFO}) ${BLUE}\W${RESET_COLOR}${GREEN}\$(__git_ps1 \" (%s)\")\$(__svn_ps1)${RESET_COLOR}${P}> "
}

# --------------------------------------------------------------------
# PATH MANIPULATION FUNCTIONS (thanks rtomayko ;) )
# --------------------------------------------------------------------
######
# Remove duplicate entries from a PATH style value while retaining
# the original order. Use PATH if no <path> is given.
# Usage: puniq [<path>]
#
# Example:
#   $ puniq /usr/bin:/usr/local/bin:/usr/bin
#   /usr/bin:/usr/local/bin
###
puniq () {
    echo "$1" |tr : '\n' |nl |sort -u -k 2,2 |sort -n |
        cut -f 2- |tr '\n' : |sed -e 's/:$//' -e 's/^://'
}

# -------------------------------------------------------------------
# USER SHELL ENVIRONMENT
# -------------------------------------------------------------------

# Set the color prompt by default when interactive
if [ -n "$PS1" ]; then
    __set_my_prompt
    export PS1
fi

# MOTD
test -n "$INTERACTIVE" -a -n "$LOGIN" && {
    uname -npsr
    uptime
}

# export PKG_CONFIG_PATH
export C_INCLUDE_PATH   CPLUS_INCLUDE_PATH
# export LIBRARY_PATH   DYLD_FALLBACK_LIBRARY_PATH

# Eventually load your custom aliases
test -f ~/.bash_aliases && . ~/.bash_aliases || true

# Eventually load your private settings (not exposed here)
test -f ~/.bash_private && . ~/.bash_private || true

# RVM specific (see http://beginrescueend.com/)
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

# condense PATH entries
PATH="$(puniq "$PATH")"
MANPATH="$(puniq "$MANPATH")"
export PATH MANPATH

