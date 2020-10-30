# If the profile was not loaded in a parent process, source
# it.  But otherwise don't do it because we don't want to
# clobber overridden values of $PATH, etc.
# if [ -z "$__ETC_PROFILE_DONE" ]; then
#     . /etc/profile
# fi
eval "$(direnv hook zsh)"
source $HOME/zsh-vim-mode/zsh-vim-mode.plugin.zsh
export PATH=~/.local/bin:$PATH
export PATH=~/.emacs.d/bin:$PATH
export EDITOR="emacseditor";
# For speeding up downloads. No account access
export GITHUB_TOKEN="7522f8a1bd31c7c06e6f5bf1cbef64974393eb64";
# export STUDIO_JDK="/nix/store/g6l8fi6l0aq4713ba9cwsry85sqvzbaq-openjdk-8u242-b08/lib/openjdk";
# export STUDIO_JDK="/run/current-system/sw/lib/openjdk";
# export ANDROID_SWT="${swt}/jars/swt.jar";
export TEA="54"

# Respect .gitignore
alias treei="fd --type f --hidden --exclude .git | tree --fromfile"
alias poin="echo \"((python-mode . ((lsp-pyright-venv-path . \"$(pwd)/.venv\")))))\" > .dir-locals.el && poetry init"
export PATH=$PATH:~/.npm-global/bin
alias sc="shadow-cljs"
# alias poru="poetry run python src/\\b"
unalias md
function md () {mkdir -p $1 && cd $1}
poru () {
    poetry run python src/$1.py "${@:2}"
}

vimsed () {vim -u NONE -c "exec \"%norm $1\"" -es '+%print|q!' "${2:-/dev/stdin}"}

echogsm () { echo $1 | fold -w2 | perl -pe "s/^0{2}$//" | tr -d "\n" | xxd -r -p}

uspars () {
    while read inp
    do
          query="(?<=from network: ' \")00.{2}00.+(?=\")"
          result=$(echo "$inp"| rg -Po "$query")
          if [[ -z "$result" ]]; then echo "$inp" ; else echo $result | xxd -r -p; fi;
    done
}

usin () { mmcli -m $2 --3gpp-ussd-initiate="*$1#" | uspars }

usre () { mmcli -m $2 --3gpp-ussd-respond="$1"    | uspars }

ussd () {
    usin $1 $2
    while read choice
    do
        usre $choice $2
    done
}

jqi() {
  cat <<< "$(jq "$1" < "$2")" > "$2"
}
# ls () {
#   for
# }

# alias mv="mvr mv "
