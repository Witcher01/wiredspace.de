---
layout: post
title: offlineimap
description: how my imap syncing setup works
---

# offlineimap

`offlineimap` is a commandline util allowing you to sync a local repository with an online one via the E-Mail syncing protocol IMAP.

## configuration

After installing `offlineimap` you will want to create a config file. This is by default located in `~/.offlineimaprc`, with further configurations in `~/.offlineimap/`.  
The configuration syntax of `offelineimap`'s config file is pretty simple. Here is a sample configuration file you can change to your liking:

	[general]
	# list of accounts to be synced, seperated by a comma
	accounts = {account1}
	starttls = yes
	ssl = yes
	# Path to file with arbitrary Python code to be loaded
	pythonfile = ~/.offlineimap/offlineimap.py
	
	[Account {account1}]
	localrepository = {account1}-local
	remoterepository = {account1}-remote
	
	[Repository {account1}-remote]
	auth_mechanisms = LOGIN
	type = IMAP
	starttls = no
	remoteuser = {username}
	remotehost = {hostname}
	# remote port should already be 993 by default
	#remoteport = 993
	sslcacertfile = /etc/ssl/certs/ca-certificates.crt
	ssl_version=tls1_2
	createfolders = False
	# Decrypt and read the encrypted password
	remotepasseval = get_pass_{account1}()
	
	[Repository {account1}-local]
	type = Maildir
	localfolders = ~/mail/{account1}

Make sure to change `{account1}` with the name of your account. This can be any identifier you want, it doesn't have to be the user-/hostname of you E-Mail service.  
The variable `pythonfile` specified a python file from which you can call functions. I set up a function to retrieve my password from a gpg-encrypted file. This is called in the `remotepasseval` variable, whose content is the function to be called.  
A thing to keep in mind: The `offlineimap` configuration file does not evaulate environment variables. So things like `$HOME` and `$XDG_CONFIG_HOME` will not work.  
Another thing is that you have to keep comments on a seperate line. Having a comment on the same line as a variable/command will make that line invalid.

## using gpg to get the password for a mailbox
### gpg encrypted password file

As mentioned before, I use gpg to retrieve the password for an inbox. I will assume you are somewhat familiar with gpg and have a private key. If you are not familiar with gpg or have a private key, you can read up about it on the [ArchWiki page for GPG](https://wiki.archlinux.org/index.php/Gpg).

First you will need to encrypt your password using gpg with the recipient set as yourself. The easiest way to do this is with this command: `gpg --encrypt -o ~/.offlineimap/.offlineimap-{account1}.gpg -r {private-key-id} -` (make sure to replace `{account1}` with the name of the account you specified above (this is to avoid confusion with multiple accounts), as well as replace `{private-key-id}` with the ID of your private gpg key). This will read the password from stdin, and since you are not passing it anything to stdin it will wait for your input on the commandline. This way you will not have to go into your history to delete the occurance of your password in plaintext. You will also not have to write the password to a file beforehand and delete it that way (which is insecure since the contents wont be written with 0's). Type in your password and hit `Ctrl-d` to send an `EOF`, signaling gpg that the end of the input is reached. You will now have a file called `.offlineimap-{account1}.gpg` in your `~/.offlineimap/` directory.

#### gpg-agent passphrase caching
To avoid having gpg-agent pop up every time you want to check your E-Mail (if you're doing this in a script, for example), you can change a few things...
gpg-agent caches passphrases for private keys. It's configuration file can be found in `~/.gnupg/gpg-agent.conf`. Put these 2 lines in there:
```
default-cache-ttl 600
max-cache-ttl 999999
```
The first line, `default-cache-ttl`, will tell gpg-agent how long to cache passphrases before they are being used again...
The second line, `max-cache-ttl`, will tell how long gpg-agent should cache passphrases in total, disregarding the `default-cache-ttl`...
Both times are given in seconds. This configuration will only ask for your passphrase if you haven't used your private key for 600 seconds (or 10 minutes).

### python script
The python script you will need is taken from the [ArchWiki page for `offlineimap`](https://wiki.archlinux.org/index.php/Offlineimap#Using_GPG). It looks like this:..

	#! /usr/bin/env python2
	from subprocess import check_output
	
	def get_pass_{account1}():
		return check_output("gpg -dq ~/.offlineimap/.offlineimap-{account1}.gpg", shell=True).strip("\n")

Change `{account1}` to the account name you are using to avoid confusion when using multiple mailboxes. If you have more than one account, add another function to the script with the other account name instead of `{account1}`. This way you will easily be able to get the different passwords by calling the different functions in your `.offlineimaprc`.

### further `.offlineimaprc` configuration
To use the newly created gpg encrypted password file and the script in `offlineimap` you need to define the `pythonfile` and `remotepasseval` variables...
I put my python script (named `offlineimap.py`) and my gpg encrypted password in `~/.offlineimap/` for easy access. If you put yours somewhere else, make sure to set the paths in the script and gpg command accordingly...
After defining `pythonfile` in the configurations `general` section with the path to your python script and the `remotepasseval` in the `account` section for your account with the function to get the password for your account you should be all set.

## using neomutt to read mail

If you want to use neomutt to read the mail `offlineimap` keeps synced between your local repository and the defined servers you will have to do the following:..
Add this section in your `.offlineimaprc`:

	[mbnames]
	enabled = yes
	filename = ~/.config/neomutt/mailboxes
	header = "mailboxes "
	peritem = "+%(accountname)s/%(foldername)s"
	sep = " "
	footer = "\n"

This will make sure your local repository is configured for neomutt to be able to read the contents, since it wont be able to do that by default...
To tell neomutt where to look for files, add this to your `neomuttrc` (or another file you have defined your account in):

	# IMAP: offlineimap
	set folder = "~/mail"
	source $XDG_CONFIG_HOME/neomutt/mailboxes
	set spoolfile = "+{account1}/INBOX"
	set record = "+{account1}/Sent\ Items"
	set postponed = "+{account1}/Drafts"

You should be all set now to browser your local mail repository with neomutt.
