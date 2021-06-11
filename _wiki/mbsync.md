---
layout: post
title: Setting up mbsync
date: 2020-12-22 22:24:00
description: actively developed alternative to offlineimap
---

# Introduction to mbsync

`mbsync` is an alternative to `offlineimap`. I decided to recently switch to `mbsync` because `offlineimap`'s development stopped and I started having problems with SSL/TLS that I wasn't about to fix.  
Setting up mbsync is easy and tedious, but I'll show you how my setup looks like so you have a simpler time than me.

# Setting up mbsync

## Configuration file

mbsync's configuration file is located at `~/.mbsyncrc`, but you can specify a different location via the `-c` flag when calling mbsync.  
The configuration file contains every account to be synced. As far as I know there is no built-in way to have different files for different accounts.

I will share my configuration file here:

	IMAPAccount {account_name}
	Host {servers_hostname}
	User {username}
	PassCmd "gpg --no-tty --for-your-eyes-only -dq {location_of_encrypted_password}"
	SSLVersion TLSv1.2
	
	IMAPStore {account_name}-remote
	Account {account_name}
	
	MaildirStore {account_name}-local
	Path ~/mail/{account_name}/
	Inbox ~/mail/{account_name}/INBOX
	SubFolders Verbatim
	
	Channel {account_name}
	Far :{account_name}-remote:
	Near :{account_name}-local:
	Patterns *
	Create Both
	Expunge Both
	SyncState *

Replace {account_name} with an identifier of your choice. You should be able to figure out what hostname and username your E-Mail provider requires yourself.  
The `PassCmd` option in this file makes it possible to not provide your password in clear text in the configuration file but get the password via a command; I get it via `gpg`. For more information how to set this up have a look at my [wiki entry for `offlineimap`](https://wiredspace.de/wiki/linux/offlineimap.html) I wrote a while ago, specifically under the section [gpg encrypted password file](https://wiredspace.de/wiki/linux/offlineimap.html#gpg-encrypted-password-file).

In the `MaildirStore` section you configure mbsync where to put the E-Mails it downloads locally. I decided to put it under `~/mail/{account_name}`, but feel free to put it somewhere else.  
Specifying `SubFolders Verbatim` tells mbsync about how the paths to your mail should look, but you shouldn't need to change this as this works, at least with neomutt.

The `Channel` section binds the remote and local stores together. mbsync used to use `Master` and `Slave` instead of `Far` and `Near`, but this is deprecated and it will notify you of this, should you use the old naming.


For more information on the configuration file make sure to read up about it on the man page. Providing a structure of the config file should help with confusion.

## Systemd timer

I decided to set up automatic fetching of mails via a systemd timer that calls a unit. This is the part that gave me a bit of problems since the timer just wouldn't run, but I got it figured out now.

I'll share my unit and timer file here.  
It's probably best to use user unit and timer files, so this is what I did. These can be found in `~/.config/systemd/user/`.

### Unit

	[Unit]
	Description=Refresh emails via mbsync
	AssertPathExists=%h/.config/neomutt
	AssertPathExists=%h/mail/
	AssertPathExists=%h/.mbsyncrc
	Wants=mbsync.timer
	
	[Service]
	Environment=XAUTHORITY=%h/.Xauthority
	Environment=DISPLAY=:0
	Type=oneshot
	ExecStart=/usr/bin/mbsync -a
	TimeoutSec=120
	
	[Install]
	WantedBy=default.target

This unit file sets a dscription and sees that the required files/folders exist, namely neomutt's config folder, the folder that stores mail and the mbsync configuration file.  
In the `Service` section I define environment variables needed for `gpg` to be able to display the pinentry dialog to decrypt the passwords for the IMAP accounts. Without these variables `gpg` is not possible to show the pinentry dialogs and will silently fail. Pay attention that you use a GUI pinentry, as the ones being displayed on the terminal obviosly won't show up.  
Setting the unit's type as `oneshot` means the unit will be blocked until the command finished executing. It also means systemd will report the unit as "activating" when it is running.  
The unit starts mbsync with the `-a` flag, meaning it should sync all accounts listed in the config file. If you want a different behaviour list the accounts you want to sync individually using the same name you used in the configuration file, {account_name}.

Now, the timeout is important. For some reason I don't understand even now mbsync would freeze and never finish, which is the reason the timer failed to activate it again. I set the timeout to 120 seconds, or 2 minutes, because, to me and for my accounts, this seems like a reasonable time to fetch mail in. You might need to change this, also depending on how often the timer will call the unit.

### Timer

	[Unit]
	Description=Run mbsync to refresh mails every 5 minutes
	Requires=mbsync.service
	
	[Timer]
	OnStartupSec=1m
	OnUnitActiveSec=5m
	Unit=mbsync.service
	
	[Install]
	WantedBy=timers.target

The timer file is similar to the unit file but has a `Timer` instead of a `Service` section.  
In the `Timer` section I specified that the timer should call the unit file a minute after the user logged on, and then every 5 minutes. I give myself the minute to let the computer boot, get a proper network connection etc.  
The `Unit` variable tells the systemd it wants to call the specified unit, which should be the name of the unit you saved.  
The `Install` section defines only the `WantedBy` variable with a value of `timer.target`, specifying, again, that this is a timer.

After setting up the unit and timer you should be able to start and enable the timer via `systemctl --user daemon-reload`, to reload the changes on disk (you will need to call this every time you change your unit and timer), and `systemctl --user enable --now mbsync.timer`.  
You can verify the timer is running by calling `systemctl --user list-timers` where your timer should be listed, along with information on when it will next file, when it last fired, etc.
