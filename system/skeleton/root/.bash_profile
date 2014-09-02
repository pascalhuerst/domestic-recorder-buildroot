# .bash_profile

export PATH=\
/bin:\
/sbin:\
/usr/bin:\
/usr/sbin:\
/usr/bin/X11:\
/usr/local/bin

umask 022

alias ll="ls -la"
export PS1="\u@\h:\w $ "

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
