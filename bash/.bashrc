#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
source /usr/share/git/completion/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=1
__prompt() {
    local status=$? host= dollar='\[\e[0m\]$'
    [[ -n $SSH_CONNECTION ]] && host='\u@\h:'
    (( status )) && dollar='\[\e[31m\]$\[\e[0m\]'
    # __git_ps1 stays quoted so a branch name is printed, never re-expanded
    PS1="$host"'\[\e[33m\]\w\[\e[90m\]$(__git_ps1 " %s")\[\e[0m\]\n'"$dollar "
}
PROMPT_COMMAND=__prompt

# Setup VulkanSDK environment
source $HOME/vulkansdk/1.4.357.1/setup-env.sh

export PATH=$PATH:~/.local/bin:~/zig
