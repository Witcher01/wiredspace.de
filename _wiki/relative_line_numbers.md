---
layout: post
title: Relative Line Numbers
description: how to view relative line numbers in vim
---

# Relative Line Numbers

By default, Vim is not showing any line numbers. You can enable them with `set number`. This will show the absolute line number on the left of the buffer.

There is also the option `show relativenumber`, which shows you the relative line number instead of an absolute...
The number of current line you're on is displayed left-bound and is the actual line number of the file you're on. Above and below will be numbers counting up, displaying how many lines that line is away from your current cursor position. These numbers will be right-bound.
