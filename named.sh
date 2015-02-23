export DOTNAMED=$HOME/.named
export NAMEDPID=/usr/local/var/named/named.pid
export NAMEDCONF=$DOTNAMED/named.conf
export NAMEDPLIST=/Library/LaunchAgents/org.isc.named.plist 

[ -f "$NAMEDPID" ] || echo "* named not currently running, but can be started with named_start"

named_updateroot () {
    # grab a current root DNS server config from internic
    curl http://www.internic.net/domain/named.root > $DOTNAMED/named.root
}

named_configure () {
    # permissions are not always as they need to be on these directories
    sudo chown $USER /usr/local/etc /usr/local/sbin
    brew install bind

    # remove if there is a symlink at our destination or rename if its an existing config
    [ -h "/usr/local/etc/named.conf" ] && rm -f /usr/local/etc/named.conf
    [ -f "/usr/local/etc/named.conf" ] && mv /usr/local/etc/named.conf /usr/local/etc/named.conf.$(date +"%s")
    ln -fs $NAMEDCONF /usr/local/etc/named.conf

    # set up list of root DNS servers
    [ -h "/usr/local/var/named/named.root" ] && rm -f /usr/local/var/named/named.root
    [ -f "/usr/local/var/named/named.root" ] && mv /usr/local/var/named/named.root /usr/local/var/named/named.root.$(date +"%s")
    ln -fs $DOTNAMED/named.root /usr/local/var/named/named.root

    # install example zone file
    ln -fs $DOTNAMED/zones/dotnamed.zone /usr/local/var/named/dotnamed.zone

    # launchctl requires root ownership
    sudo chown root $DOTNAMED/org.isc.named.plist

    # install the plist so that the service starts on reboot
    echo $NAMEDPLIST 
    [ -e "${NAMEDPLIST}" ] && sudo rm -f $NAMEDPLIST
    sudo ln -fs $DOTNAMED/org.isc.named.plist $NAMEDPLIST

    named_start
}

named_start () {
    sudo launchctl load -w $NAMEDPLIST
}

named_stop () {
    sudo launchctl unload -w $NAMEDPLIST
}

named_reload () {
    sudo kill -HUP $(cat ${NAMEDPID})
}

named_restart () {
    named_stop
    named_start
}
