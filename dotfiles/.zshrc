# If the profile was not loaded in a parent process, source
# it.  But otherwise don't do it because we don't want to
# clobber overridden values of $PATH, etc.
# if [ -z "$__ETC_PROFILE_DONE" ]; then
#     . /etc/profile
# fi
eval "$(direnv hook zsh)"
source $HOME/zsh-vim-mode/zsh-vim-mode.plugin.zsh
export PATH=~/doom-emacs/bin:$PATH
export EDITOR="emacs";
# For speeding up downloads. No account access
export GITHUB_TOKEN="7522f8a1bd31c7c06e6f5bf1cbef64974393eb64";
# export STUDIO_JDK="/nix/store/g6l8fi6l0aq4713ba9cwsry85sqvzbaq-openjdk-8u242-b08/lib/openjdk";
# export STUDIO_JDK="/run/current-system/sw/lib/openjdk";
# export ANDROID_SWT="${swt}/jars/swt.jar";
export TEA="54"
