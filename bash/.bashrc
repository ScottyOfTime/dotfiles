#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
# Only show the last 2 dirs of \w (e.g. ~/.../foo/bar)
PROMPT_DIRTRIM=2
PS1='[\[\e[38;5;74m\]\u\[\e[0m\]@\[\e[38;5;176m\]\h\[\e[0m\]:\w]\\$ '

# Setup VulkanSDK environment
source $HOME/vulkansdk/1.4.357.1/setup-env.sh

export PATH=$PATH:~/.local/bin:~/zig
