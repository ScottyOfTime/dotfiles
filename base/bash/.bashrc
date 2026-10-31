[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
source /usr/share/git/completion/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=1  # * unstaged, + staged
__prompt() {
    local dollar='$'
    (( $? )) && dollar='\[\e[31m\]$'
    # __git_ps1 stays quoted so a branch name is printed, never re-expanded
    PS1='[\[\e[34m\]\u\[\e[0m\]@\[\e[35m\]\h\[\e[0m\]:\[\e[33m\]\w\[\e[0m\]]\[\e[32m\]$(__git_ps1 " (%s)")\[\e[0m\]\n'"$dollar"'\[\e[0m\] '
}
PROMPT_COMMAND=__prompt

[[ -f $HOME/vulkansdk/1.4.357.1/setup-env.sh ]] && source $HOME/vulkansdk/1.4.357.1/setup-env.sh

export PATH=$PATH:~/.local/bin:~/zig
