#
# ~/.profile
#

[[ -f ~/.bash_profile ]] && . ~/.bash_profile

# Read sysadmin configuration
if [ -f "$HOME/.sysadminrc" ]; then
   . "$HOME/.sysadminrc"
fi
