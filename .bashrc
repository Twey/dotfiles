if [ -z "$SSH_AUTH_SOCK" ]
then
    {
        eval $(ssh-agent)
        ssh-add ~/.ssh/id_ed25519
    } &> /dev/null
fi

function lookup {
    pushd . &>/dev/null
    local target=$1
    while [ ! -f "$target" ] && cd .. && [ "$PWD" != "/" ]
    do
        :
    done

    if [ -f "$target" ]
    then
        realpath "$target"
        ret=$?
        popd &>/dev/null
        return $ret
    else
        >&2 echo "no $target found"
        popd &>/dev/null
        return 1
    fi
}

function nix-shell-with-options {
    local opts=()
    while [ $# -ne 0 ] && [ "x$1" != "x--" ]
    do
        opts+=("$1")
        shift
    done
    shift
    nix-shell "${opts[@]}" --show-trace --command "$(printf '%q ' "$@")"
}

function nix-shell-with-options-and-file {
    nixenv="$(lookup shell.nix)" \
        && nix-shell-with-options "$nixenv" "$@"
}

function nx {
    nix-shell-with-options-and-file --pure -- "$@"
}

function nxu {
    nix-shell-with-options-and-file --pure --option sandbox relaxed -- "$@"
}

function nxi {
    nix-shell-with-options-and-file -- "$@"
}

function ncmd {
    nix-shell-with-options -p "$1" -- "$@"
}
