# Created by newuser for 4.3.10

# Characters considered part of words when deleting or navigating over words in the command prompt
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

## Completion
autoload -Uz compinit
compinit
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*:descriptions' format '%U%F{cyan}%d%f%u'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' special-dirs true
#setopt list_ambiguous

## Aliases
alias ll='ls -lah --color'
alias mc='mc --nomouse'
alias mcedit='mcedit --nomouse'

# Setup keyboard commands
# First populate table with keys, see `man 5 terminfo`
typeset -A key
key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# Assign commands to keys
[[ -n "${key[Home]}"    ]]  && bindkey  "${key[Home]}"    beginning-of-line
[[ -n "${key[End]}"     ]]  && bindkey  "${key[End]}"     end-of-line
[[ -n "${key[Insert]}"  ]]  && bindkey  "${key[Insert]}"  overwrite-mode
[[ -n "${key[Delete]}"  ]]  && bindkey  "${key[Delete]}"  delete-char
[[ -n "${key[Up]}"      ]]  && bindkey  "${key[Up]}"      up-line-or-history
[[ -n "${key[Down]}"    ]]  && bindkey  "${key[Down]}"    down-line-or-history
[[ -n "${key[Left]}"    ]]  && bindkey  "${key[Left]}"    backward-char
[[ -n "${key[Right]}"   ]]  && bindkey  "${key[Right]}"   forward-char

# Finally, make sure the terminal is in application mode, when zle is active.
# Only then are the values from $terminfo valid.

function zle-line-init () {
    if (( ${+terminfo[smkx]} )); then
  echoti smkx
    fi
}
function zle-line-finish () {
    if (( ${+terminfo[rmkx]} )); then
  echoti rmkx
    fi
}

zle -N zle-line-init
zle -N zle-line-finish

bindkey ";5D" backward-word
bindkey ";5C" forward-word

autoload -U history-search-end

zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

autoload up-line-or-beginning-search
autoload down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

[[ -n "${key[Up]}"      ]]  && bindkey   "${key[Up]}"       up-line-or-beginning-search
[[ -n "${key[Down]}"    ]]  && bindkey   "${key[Down]}"    down-line-or-beginning-search

function title() {
  # escape '%' chars in $1, make nonprintables visible
  a=${(V)1//\%/\%\%}

  # Truncate command, and join lines.
  a=$(print -Pn "%40>...>$a" | tr -d "\n")

  case $TERM in
  screen)
    print -Pn "\e]2;$2 $a\a" # plain xterm title: "HOSTNAME CWD"
    print -Pn "\ek$2 $a\e\\"      # screen title (in ^A"): "HOSTNAME(CWD) CMD"
    print -Pn "\e_$2   \e\\"   # screen location: "HOSTNAME"
    ;;
  xterm*|rxvt)
    print -Pn "\e]2;$2 $a\a" # plain xterm title: "HOSTNAME: CWD"
    ;;
  esac
}

function preexec() {
  title ${(V)1//\%/} "%M"
}

autoload -U colors && colors

git_prompt() {
  if (git rev-parse --git-dir 1>/dev/null 2>/dev/null)
  then
    gitdir=$(git rev-parse --git-dir)
    if [ "$(whoami)" = "$(stat -c %U $gitdir 2>/dev/null || stat -f %Su $gitdir)" ]
    then
      localbranch=$(git symbolic-ref HEAD 2>/dev/null)
      branch=$(echo "$localbranch" | cut -d'/' -f3)
      if [ -z "$branch" ]
      then
        echo ""
      else
        refs=$(git show-ref --head)
        localhead=$(echo "$refs" | grep " $localbranch\$" | cut -d ' ' -f 1)
        remote=$(echo "$localbranch" | sed 's:/heads/:/remotes/origin/:')
        remotehead=$(echo "$refs" | grep " $remote\$" | cut -d ' ' -f 1)
        if [ -z "$remotehead" ]
        then
          remotehead=$(git log -n 1 --pretty=format:'%H' --grep=git-svn-id: --first-parent -1)
        fi
        if [ -z "$localhead" ] || [ -z "$remotehead" ]
        then
          echo " %{$fg_bold[red]%}$branch%{$reset_color%}"
        else
          gitstatus="$(git status --porcelain 2>/dev/null | grep -v '^??' | grep -v '^!!' 2>/dev/null)"
          if [ ! -z "$gitstatus" ]
          then
             echo " %{$fg_bold[yellow]%}$branch%{$reset_color%}"
          else
            if [ ! "$localhead" = "$remotehead" ]
            then
              echo " %{$fg_bold[green]%}$branch%{$reset_color%}"
            else
              echo " %{$fg[green]%}$branch%{$reset_color%}"
            fi
          fi
        fi
      fi
    fi
  fi
}

svn_prompt() {
  dir="."
  svndir=""
  while [ -d "$dir" ] ; do
    if [ -d "$dir/.svn" ] ; then
      svndir="$dir"
    else
      if [ ! -z "$svndir" ] ; then
        break
      fi
    fi
    dir="$dir/.."
  done
  if [ ! -z "$svndir" ]; then
    if [ "$(whoami)" = "$(stat -c %U $svndir)" ] ; then
      info=$(cd "$svndir" ; svn info 2>/dev/null)
      url=$(echo "$info" | grep -E '^URL: ' | cut -d ' ' -f 2)
      root=$(echo "$info" | grep -E 'Repository Root: ' | cut -d ' ' -f 3)
      head=$(echo "$info" | grep -E 'Revision: ' | cut -d ' ' -f 2)
      branch=$(echo ${url#$root} | cut -d '/' -f 2)
      if [ -z "$branch" ] ; then
        echo ""
      else
        svnstatus="$(cd "$svndir" ; svn status -q 2>/dev/null)"
        if [ ! -z "$svnstatus" ] ; then
          echo " %{$fg_bold[yellow]%}$branch%{$reset_color%}"
        else
          echo " %{$fg[yellow]%}$branch%{$reset_color%}"
        fi
      fi
    fi
  fi
}

setopt prompt_subst
setopt promptsubst

#PR_PWDLEN

local gitpromptcmd='$(git_prompt)$(svn_prompt)'
if [[ $EUID -eq 0 ]]
then
  PROMPT="[%{$fg_bold[red]%}%n%{$reset_color%}@%{$fg[cyan]%}%m%{$reset_color%} %{$fg_bold[blue]%}%*%{$reset_color%} %30<...<%/%<<${gitpromptcmd}]%(?.%{$fg[green]%}$%{$reset_color%}.%{$fg[red]%}$%{$reset_color%}) "
else
  PROMPT="[%n%{$reset_color%}@%{$fg[cyan]%}%m%{$reset_color%} %{$fg_bold[blue]%}%*%{$reset_color%} %30<...<%/%<<${gitpromptcmd}]%(?.%{$fg[green]%}$%{$reset_color%}.%{$fg[red]%}$%{$reset_color%}) "
fi

svn-log-helper()
{
  svn log "$@" | sed -e 's/^\(.*\)|\(.*\)| \(.*\) \(.*\):[0-9]\{2\} \(.*\) (\(...\).*) |\(.*\)$/\o33\[0;33m\1\o33[0m|\o33\[1;34m\2\o33[0m| \o33\[0;32m\3 \4 (\6, \5)\o33[0m |\7/'
}

svn-log()
{
  svn-log-helper "$@" | less -R
}

svn-log-p-helper()
{
  for c in $(svn log "$@"  | grep -e '^r[0-9]' | cut -f1 -d ' ' | sed s/r/-c/); do
    svn-log $c
    svn diff --force $c "$@"
  done
}

svn-log-p()
{
  svn-log-p-helper "$@" | less -R
}

# Renames multiple files. Use -n to simulate. Example: zmv -n -W '*.gz' '*.zip'
autoload zmv

# Fast cd: cdf
ZSH_BOOKMARKS="$HOME/.zshbookmarks"

function add2cdf() {
  touch ~/.zshbookmarks
  grep -qx $(pwd) ~/.zshbookmarks || pwd >> "$ZSH_BOOKMARKS"
}

function cdf() {
  if [ -d "$1" ]; then
    cd "$1"
    return 0
  fi
  local index
  local entry
  index=0
  for entry in $(echo "$1" | tr '/' '\n'); do
    if [[ $index == "0" ]]; then
      local CD
      CD=$(egrep -i "^$entry\\s" "$ZSH_BOOKMARKS" | sed "s#^$entry\\s\+##")
      echo "CD=$CD"
      if [ -z "$CD" ]; then
        echo "$0: no such bookmark: $entry"
        break
      else
        cd "$CD" 2>/dev/null
      fi
    else
      cd "$entry" 2>/dev/null
      if [ "$?" -ne "0" ]; then
        break
      fi
    fi
    let "index++"
  done
}

function _cdf() {
  reply=($(cat "$ZSH_BOOKMARKS" | grep -i "$1"))
}

compctl -U -K _cdf cdf

if [ "$TERM" = "fbterm" ] || [ "$TERM" = "linux" ]
then
    echo -en "\e]P7dedede" #lightgrey
    echo -en "\e]PFdedede" #white
fi

export PATH=$HOME/bin:/usr/local/bin:/opt/bin:/usr/sbin:/sbin:/usr/bin:$PATH

export HISTSIZE=10000000
export SAVEHIST=$HISTSIZE
export HISTFILE=~/.zshhistory
export EXTENDED_HISTORY=1
setopt SHARE_HISTORY
setopt APPEND_HISTORY
