export LANG=
export EDITOR=vim
export GIT_EDITOR=vim

#if running bash
if [ -n "${BASH_VERSION}" ]; then
  if [ -f "${HOME}/.bashrc" ]; then
    source "${HOME}/.bashrc"
  fi
fi
GIT_SSH=/usr/bin/ssh.exe
