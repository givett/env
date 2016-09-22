#!/bin/bash
#
# env/bashrc - Making bash feel like home
#

# VIM #################################################
export EDITOR=vim

# COLORS ##############################################
export CLICOLOR=1 # Mac OSX

# Command Aliases #####################################
if [[ -x /usr/bin/colordiff ]]; then
	alias diff='/usr/bin/colordiff -u'
else
	alias diff='/usr/bin/diff -u'
fi

# Configure Environment ###############################
# V=0 causes quiet output from automake builds
export V=0

# Bash Prompts ########################################

PROMPT_HOST=$(hostname -f)
if [[ -x /sbin/ip ]]; then
	PROMPT_ADDR=$(/sbin/ip addr show 2>/dev/null | awk '/inet.* scope global / { print $2; exit }')
elif [[ -x /sbin/ifconfig ]]; then
	PROMPT_ADDR=$(/sbin/ifconfig en0 2>/dev/null | awk '/inet / { print $2; exit }')
else
	PROMPT_ADDR="::unknown::"
fi
[ -z $PROMPT_ADDR ] || PROMPT_ADDR="$PROMPT_ADDR "

PROMPT_SHLVL=""
if [[ -z $TMUX && $SHLVL != 1 ]]; then
	PROMPT_SHLVL="%C[sh${SHLVL}] "
fi
if [[ -n $TMUX && $SHLVL != 2 ]]; then
	PROMPT_SHLVL="%C[sh$(( SHLVL - 1 ))] "
fi

PROMPT_GO=""
if [[ -n ${GOENV} ]]; then
	PROMPT_GO="%K[${GOENV}]|"
fi

export PS1=$(echo "$PROMPT_SHLVL+$PROMPT_GO%B[\t]:%Y[\!]:"'$(r=$?; test $r -ne 0 && echo "%R[$r]" || echo "%Y[$r]")'"$PROMPT_TT %M[$PROMPT_ADDR]%G[\u@$PROMPT_HOST] %B[\w\n]%G[→] " | $HOME/env/colorize);

type git >/dev/null 2>&1
if [[ $? == 0 ]]; then
	export PS0="%{%[\e[1;34m%]%b%[\e[00m%]:%[\e[1;33m%]%i%[\e[00m%]%}%{%[\e[1;31m%]%c%u%f%t%[\e[00m%]) %}$PS1 "
	export PROMPT_COMMAND='export PS1=$($HOME/env/gitprompt c=\+ u=\* statuscount=1)'
fi

case $TERM in
screen)
	if [[ -n $PROMPT_COMMAND ]]; then
		export PROMPT_COMMAND="$PROMPT_COMMAND;";
	fi
	export PROMPT_COMMAND=$PROMPT_COMMAND'echo -ne "\033]2;${USER}@${PROMPT_HOST} ${PROMPT_ADDR}${PWD}\033k${PROMPT_HOST}\033\\"'
	;;
esac

echo $PATH | grep -q "$HOME/bin";
if [[ $? != 0 ]]; then
	PATH="$PATH:$HOME/bin"
fi
if [[ "$(command -v brew)" != "" ]]; then
	PATH="$(brew --prefix coreutils)/libexec/gnubin:/usr/local/sbin:/usr/local/bin:$PATH"
fi

if [[ -d $HOME/sw ]]; then
	PATH="$PATH:$HOME/sw/sbin:$HOME/sw/bin"
	export LD_LIBRARY_PATH="$HOME/sw/lib"
	export LDFLAGS="-L$HOME/sw/lib"
	export CFLAGS="-I$HOME/sw/include"
	export CPPFLAGS=$CFLAGS
	export PKG_CONFIG_PATH="$HOME/sw/lib/pkgconfig"
fi

for FILE in $HOME/env/bash/*; do
	[ -f $FILE ] && source $FILE
done

# Server-specific overrides ###########################

if [ -f ~/.bashrc.local ]; then
	. ~/.bashrc.local
fi

eval $(dircolors 2>/dev/null)
if ! ls --color=auto /enoent 2>&1 >/dev/null | grep -q illegal; then
	alias ls="ls --color=auto"
fi

pathify
