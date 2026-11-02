[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
# git-prompt.sh lives in a different place on each distro
for f in /usr/share/git/completion/git-prompt.sh /usr/lib/git-core/git-sh-prompt \
         /usr/share/git-core/contrib/completion/git-prompt.sh; do
    [[ -f $f ]] && { source "$f"; break; }
done
type __git_ps1 &>/dev/null || __git_ps1() { :; }
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
export EDITOR=$(command -v nvim || command -v vim || echo vi)
export VISUAL=$EDITOR
