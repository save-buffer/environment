# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="spaceship"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    colored-man-pages
    colorize
    github
    osx
    web-search
    emacs
    python
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='emacs'
 else
   export EDITOR='emacs'
 fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
 # alias ohmyzsh="mate ~/.oh-my-zsh"
autoload -Uz compinit
compinit
SPACESHIP_PROMPT_ORDER=(
  time          # Time stampts section
  user          # Username section
  dir           # Current directory section
  host          # Hostname section
  git           # Git section (git_branch + git_status)
  package       # Package version
  dotnet        # .NET section
#  exec_time     # Execution time
  exit_code     # Exit code section
  char          # Prompt character
)
#SPACESHIP_RPROMPT_ORDER = (time)
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_SEPARATE_LINE=false
SPACESHIP_CHAR_SYMBOL=$
SPACESHIP_CHAR_SUFFIX=' '
SPACESHIP_CHAR_COLOR_SUCCESS=045
SPACESHIP_CHAR_COLOR_FAILURE=196
SPACESHIP_TIME_SHOW=true
SPACESHIP_TIME_COLOR=033
SPACESHIP_USER_PREFIX=
SPACESHIP_USER_SUFFIX=:
SPACESHIP_USER_COLOR=045
SPACESHIP_DIR_PREFIX=
SPACESHIP_USER_SHOW=always
SPACESHIP_GIT_BRANCH_COLOR=135
SPACESHIP_DIR_COLOR=045
SPACESHIP_DIR_TRUNC=0

export LSCOLORS=excxcxcxfxegedabagacad
export LS_COLORS='di=34:ln=32:so=32:pi=32:ex=35:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
function calc
{
    if [ $# -eq 0 ]; then echo 'pass match command arguments, like calc (2^32/17) + 3'; return; fi;
    echo $* | bc -l
}

function flamegraph
{
    sudo perf record -F 997 --call-graph lbr -p $(pgrep $1 | head -n 1) -g -o perf.data -- sleep 10
    sudo chown $USER perf.data
    perf script -i perf.data | ~/.flamegraph/stackcollapse-perf.pl | ~/.flamegraph/flamegraph.pl > flamegraph.svg
    rm perf.data
}

alias attu="ssh -X samovar@attu.cs.washington.edu"
alias vergil="ssh -X samovar@vergil.u.washington.edu"
alias xor="ssh -X -p 425 samovar@xor.cs.washington.edu"
