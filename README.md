# dotnamed
A simple framework for setting up a DNS caching daemon on a mac using BIND.

ISP-based DNS servers tend to be slow and frustrating to use.  Sometimes you don't want to wait for TTLs to pass after a zone change.  Besides that, public DNS and shared DNS caches combined with SSL exploits are common attack vectors.  After setting up a caching server at home, I realized I wanted something for my laptop _to go_ and that's what this is.

The options for setting up a DNS caching daemon under OS X are pretty limited.  I have a long history of using BIND, and its available in homebrew.  I know configuring BIND is not straightforward for most, so I packaged up my config here for a dead simple caching server that only listens on 127.0.0.1.  There is also an example zone file, if you want to host your own domains in this instance, you can just copy/modify that config (zones/dotnamed.zone).  It would be trivial to slave a zone off of another server, if you have corporate DNS or something along those lines.

INSTALL
===========

It is required that you have homebrew installed to use this.  Its really simple, though.  Check out http://brew.sh for details.

Clone repository to ~/.named.  If you want to install elsewhere, that is fine, but you'll need to change the first line of named.sh to reflect the new location.

Full install process:

```
git clone git@github.com:dw-io/dotnamed.git ~/.named
source ~/.named/named.sh
named_configure
```

This should install and start named.  It will load into launchd so it will be available after reboot as well.  There are a few control functions in named.sh.  If you always want them to be available, do this:

```
echo "source ~/.named/named.sh" >> ~/.bash_profile
```

USAGE
=====

once named is configured with the above call, you can go ahead and add 127.0.0.1 in as your primary and/or only DNS server through network preferences.  Its worth testing to make sure its working before you do that, though.  Try this:

```
host google.com 127.0.0.1
```

If its working, you'll get something like, but not exactly this back:

```
Using domain server:
Name: 127.0.0.1
Address: 127.0.0.1#53
Aliases: 

google.com has address 173.194.123.3
google.com has address 173.194.123.8
google.com has address 173.194.123.14
google.com has address 173.194.123.9
google.com has address 173.194.123.5
google.com has address 173.194.123.0
google.com has address 173.194.123.4
google.com has address 173.194.123.2
google.com has address 173.194.123.7
google.com has address 173.194.123.1
google.com has address 173.194.123.6
google.com has IPv6 address 2607:f8b0:4006:80a::1006
google.com mail is handled by 50 alt4.aspmx.l.google.com.
google.com mail is handled by 20 alt1.aspmx.l.google.com.
google.com mail is handled by 10 aspmx.l.google.com.
google.com mail is handled by 40 alt3.aspmx.l.google.com.
google.com mail is handled by 30 alt2.aspmx.l.google.com.
```

You will likely get no results if its misconfigured or a timeout, if the daemon isn't running.

Assuming you added the named.sh file to your .bash_profile, you will have a few handy tools at your disposal.  Here is what they do:

To restart named:

```
named_restart
```

To stop named and prevent it from starting again on reboot:

```
named_stop
```

To start named and ensure it starts on reboot:

```
named_start
```

To reload named after a config change:

```
named_reload
```

To update root DNS server list (it changes from time to time but very rarely):

```
named_updateroot
```

NOTES
=====

- I've noticed that queries fail for the first few seconds after starting up named.
- The named log gets written here:  /usr/local/var/log/named/named.log
- This has only been tested on OS 10.9 and 10.10
- For security reasons, this will only answer on 127.0.0.1.  If you want to open it up to other hosts, you will need to modify listen-on, allow-query and allow-recursion in named.conf.  Read and be careful.