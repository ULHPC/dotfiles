#
# ~/.bash_profile
#

for beforehook in ~/.bash.before.d/* ; do
    . "$beforehook"
done

[[ -f ~/.bashrc ]] && . ~/.bashrc

if [ -n "$(which brew 2>/dev/null)" ]; then
    if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
        . "$(brew --prefix)/etc/bash_completion"
    fi
fi
