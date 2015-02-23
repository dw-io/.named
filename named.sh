export DOTNAMED=$HOME/.named
export NAMEDPID=$DOTNAMED/named.pid
export NAMEDCONF=$DOTNAMED/named.conf
export NAMEDPLIST=$DOTNAMED/org.isc.named.plist 

[ -f "$NAMEDPID" ] || echo "* named not currently running, but can be started with named_start"

named_configure () {
    # permissions are not always as they need to be on these directories
    sudo chown $USER /usr/local/etc /usr/local/sbin
    brew install bind

    # grab a current root DNS server config from internic
    wget --user=ftp --password=ftp ftp://ftp.rs.internic.net/domain/db.cache -O /usr/local/var/named/named.root

    # remove if there is a symlink at our destination or rename if its an existing config
    [ -h "/usr/local/etc/named.conf" ] && rm -f /usr/local/etc/named.conf
    [ -f "/usr/local/etc/named.conf" ] && mv /usr/local/etc/named.conf /usr/local/etc/named.conf.$(date +"%s")

    ln -fs $NAMEDCONF /usr/local/etc/named.conf

    # launchctl requires root ownership
    sudo chown root $NAMEDPLIST
    sudo launchctl load $NAMEDPLIST
}

named_start () {
    sudo launchctl load $NAMEDPLIST
}

named_stop () {
    sudo launchctl unload $NAMEDPLIST
}

named_hup () {
    sudo kill -HUP $(cat ${NAMEDPID})
}

named_restart () {
    named_stop
    named_start
}
