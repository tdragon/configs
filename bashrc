SSH_PRIVATE="$HOME/.ssh/id_rsa"
SSH_ENV="$HOME/.ssh/environment"
function start_agent {
    echo "Initializing new SSH agent..."
    ( /usr/bin/ssh-agent | sed 's/^echo/#echo/' ) > "${SSH_ENV}"
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add $SSH_PRIVATE
}
# Source SSH settings, if applicable
function start_agent_if_needed {
    if [[ -f "${SSH_ENV}" ]]
    then
        . "${SSH_ENV}" > /dev/null
        ( ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ ) > /dev/null || { start_agent; }
    else
        start_agent;
    fi
}


function _git_prompt() {
    local git_status="`git status -unormal 2>&1`"
    if ! [[ "$git_status" =~ Not\ a\ git\ repo ]]; then
        if [[ "$git_status" =~ nothing\ to\ commit ]]; then
            local ansi=32
        elif [[ "$git_status" =~ nothing\ added\ to\ commit\ but\ untracked\ files\ present ]]; then
            local ansi=35
        else
            local ansi=33
        fi  
        echo -n '\[\e[0;33;'"$ansi"'m\]'"$(__git_ps1)"'\[\e[0m\]'
    fi
}



start_agent_if_needed

export SVN_EDITOR=vim


# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
# ... or force ignoredups and ignorespace
export HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set a default prompt of: user@host and current_directory
#PS1='\[\033[01;34m\]\u:\w\$\[\033[00m\] ' # use \h to display host

function _prompt_command() {
  PS1="\[\033[36m\]\w\[\033[0m\]\[\033[0m\]`_git_prompt`\[\033[1;33m\]@ \[\033[0m\]"
}

PROMPT_COMMAND=_prompt_command

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
#if [ -f /etc/bash_completion ]; then
#    . /etc/bash_completion
#fi

#alias in separate file
if [[ -f ~/.alias ]]; then
    source ~/.alias
fi

#always create core dumps
ulimit -c unlimited


export PERL_LOCAL_LIB_ROOT="$HOME/perl5";
export PERL_MB_OPT="--install_base $HOME/perl5";
export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5";
export PERL5LIB="$HOME/perl5/lib/perl5/cygwin-thread-multi-64int:$HOME/perl5/lib/perl5";
export PATH="$HOME/perl5/bin:$PATH";

export TERM='xterm-256color'

