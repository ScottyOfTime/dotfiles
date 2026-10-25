#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\[\e[38;5;74m\]\u\[\e[0m\]@\[\e[38;5;176m\]\h\[\e[0m\]:\w]\n$ '

# Setup VulkanSDK environment
source $HOME/vulkansdk/1.4.357.1/setup-env.sh

export PATH=$PATH:~/.local/bin:~/zig
