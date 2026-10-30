#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
# prompt: [user@host:dir] (branch *+), then $ (red after a failed command).
# ANSI colour names follow ghostty's theme, so darkman switches them.
source /usr/share/git/completion/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=1  # * unstaged, + staged
__prompt() {
    local dollar='$'
    (( $? )) && dollar='\[\e[31m\]$'
    # __git_ps1 stays quoted so a branch name is printed, never re-expanded
    PS1='[\[\e[34m\]\u\[\e[0m\]@\[\e[35m\]\h\[\e[0m\]:\[\e[33m\]\w\[\e[0m\]]\[\e[32m\]$(__git_ps1 " (%s)")\[\e[0m\]\n'"$dollar"'\[\e[0m\] '
}
PROMPT_COMMAND=__prompt

# Setup VulkanSDK environment
source $HOME/vulkansdk/1.4.357.1/setup-env.sh

export PATH=$PATH:~/.local/bin:~/zig
