if status is-interactive
    # Commands to run in interactive sessions can go here
    zoxide init fish | source
    alias cat="moar"
    alias cd="z"
    alias ls="eza"
    alias top="btm"
    alias vim="nvim"
    alias config="/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME"
    alias aider4o 'mkdir -p ./.aider && aider --4o --openai-api-key (op read op://private/openai/credential)'
    alias git_clean 'git branch --merged | grep -Ev "(^\*|^\+|master|main|dev)" | xargs --no-run-if-empty git branch -D'

    set -x MOAR "--no-linenumbers --style=tokyonight-storm"
    set -x PAGER "moar"
    fish_add_path ~/Library/Android/sdk/platform-tools/
end

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end
