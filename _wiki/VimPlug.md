---
layout: wiki
title: vim-plug
description: the plugin manager i currently use to manage my vim plugins
---

# vim-plug

## Installation
vim-plug is available in the AUR. For other installation methods, visit [vim-plug's Github page](https://github.com/junegunn/vim-plug).

## Usage
To start using vim-plug, add these lines to your .vimrc:

 call plug#begin('~/.vim/plugged')
 call plug#end()

Between these lines is where you put your plugins. You just paste a part of the server url in simple quotation marks after `Plug`. For example:

 call plug#begin('~/.vim/plugged')
 Plug 'vimwiki/vimwiki'
 call plug#end()

To install plugins once you listed them in your .vimrc, execute the command `:PlugInstall` in vim...
To deinstall a plugin, remove it from your .vimrc and execute `:PlugClean`...
If you want to update your plugins, type `:PlugUpdate`.
