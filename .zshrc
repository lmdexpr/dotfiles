# (d) is default on

#------------------------------
#General Settings
#------------------------------
export EDITOR=vim
export BROWSER=opera
export LANG=ja_JP.UTF-8
export KCODE=u
export AUTOFEATURE=true
export TERM=xterm-256color

export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on'

export JDBC_DATABASE_URL='jdbc:postgresql://testuser@localhost/testdb'

export GISTY_DIR="$HOME/src/gists"
export GISTY_ACCESS_TOKEN=""

export OCAMLPARAM="_,bin-annot=1"

export PATH=$HOME/.cabal/bin:$HOME/.local/bin:$HOME/.opam/4.01.0/bin:$PATH
export PATH=$HOME/.ghc-mod/bin:$HOME/.xmonad:$PATH
export PATH=$HOME/.gem/ruby/2.3.0/bin:$PATH
export PATH=/opt/local:/usr/local/bin/:$PATH
export PATH=~/.rakudobrew/bin:~/.rakudobrew/moar-nom/install/share/perl6/site/bin:$PATH

export CACHE_DIR=/$HOME/.mikutter/cache

export RLWRAP_COMMAND=`which rlwrap`

bindkey -v

setopt no_beep
setopt auto_cd
setopt auto_pushd
setopt correct
setopt magic_equal_subst
setopt prompt_subst
setopt notify
setopt equals

##Complement ###
autoload -U compinit; compinit
setopt auto_list
setopt auto_menu
setopt list_packed
setopt list_types
bindkey "^[[Z" reverse-menu-complete
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

##Glob ###
setopt extended_glob
unsetopt caseglob

##History ###
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt bang_hist
setopt extended_history
setopt hist_ignore_dups
setopt share_history
setopt hist_reduce_blanks

autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

function history-all { history -E 1 }


#------------------------------
#Look And Feel Settings
#------------------------------
##Prompt ###
#source $HOME/.zsh/git-prompt.sh

autoload -U colors; colors
autoload -Uz vcs_info

setopt correct
setopt re_match_pcre
setopt prompt_subst
setopt transient_rprompt

#precmd () {
#    RPROMPT='echo $(__git_ps1 "[%s]")|sed -e s/%/%%/|sed -e s/%%%/%%/'
#}

#GIT_PS1_SHOWDIRTYSTATE=1
#GIT_PS1_SHOWSTASHSTATE=1
#GIT_PS1_SHOWUNTRACKEDFILES=1
#GIT_PS1_SHOWUPSTREAM="auto"
#GIT_PS1_DESCRIBE_STYLE="branch"
#GIT_PS1_SHOWCOLORHINTS=0

KAO_TMP="(*'-'"
KAO="$KAO_TMP)"
KAOP="$KAO_TMP%)"
KAO_KANASHI="(*'~'"
KAO_K="$KAO_KANASHI%)"

PROMPT="
[%n] %{${fg[yellow]}%}%~%{${reset_color}%}
%(?.%{$fg[green]%}.%{$fg[cyan]%})%(?!$KAO <!$KAOP? <)%{${reset_color}%} "

PROMPT2='[%n]> '

SPROMPT="%{$fg[red]%}%{$suggest%}$KAO_K? < %B%r%b %{$fg[red]%}? [y,n,a,e]:${reset_color} "


##Ls Color ###

alias ls="ls --color=auto -GF"

#zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'

#------------------------------
#Other Settings
#------------------------------
##RVM ###
if [[ -s ~/.rvm/scripts/rvm ]] ; then source ~/.rvm/scripts/rvm ; fi

##rakudobrew ###
eval "$(rakudobrew init -)"

##Aliases ###
alias l="ls -I contestapplet.conf -I contestapplet.conf.bak"
alias la="ls -A"
alias ll="ls -lF"
alias cls="clear;l"

alias zshrc="vim $HOME/.zshrc"
alias vimrc="vim $HOME/.vimrc"
alias xmonadrc="vim $HOME/.xmonad/xmonad.hs"

alias reload="source $HOME/.zshrc"

#alias cabal="LANG=C cabal"

alias ocaml="$RLWRAP_COMMAND ocaml"
alias ocamltter="$RLWRAP_COMMAND ocamltter"

alias scheme="$RLWRAP_COMMAND scheme"
alias gosh="$RLWRAP_COMMAND gosh"

alias dualdisp="xrandr --output HDMI1 --auto --output eDP1 --left-of HDMI1"
alias dualdisable="xrandr --output HDMI1 --off"

alias weather="curl -4 wttr.in/Kumamoto"

alias msfconsole="msfconsole -x \"db_connect ${USER}@msf\""

## OPAM configuration ###
. /$HOME/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
