#
# ~/.bash_profile
#

if [[ -d ~/.bash.before.d ]] ; then
    for beforehook in ~/.bash.before.d/* ; do
        . "$beforehook"
    done
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc

if [ -n "$(which brew 2>/dev/null)" ]; then
    if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
        . "$(brew --prefix)/etc/bash_completion"
    fi
fi

# Read sysadmin configuration
if [ -f "$HOME/.sysadminrc" ]; then
   . "$HOME/.sysadminrc"
fi
