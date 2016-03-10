-*- mode: markdown; mode: visual-line; fill-column: 80 -*-

[![Licence](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](http://www.gnu.org/licenses/gpl-3.0.html) ![By ULHPC](https://img.shields.io/badge/by-ULHPC-blue.svg)  [![Build Status](https://travis-ci.org/ULHPC/dotfiles.svg?branch=feature/falkor_import)](https://travis-ci.org/ULHPC/dotfiles) [![github](https://img.shields.io/badge/git-github- lightgray.svg)](https://github.com/ULHPC/dotfiles) [![ULHPC/dotfiles issues](https://img.shields.io/github/issues/ULHPC/dotfiles.svg)](https://github.com/ULHPC/dotfiles/issues) ![](https://img.shields.io/github/stars/ULHPC/dotfiles.svg) [![Documentation Status](https://readthedocs.org/projects/ulhpc-dotfiles/badge/?version=latest)](https://readthedocs.org/projects/ulhpc-dotfiles/?badge=latest)

      Time-stamp: <Mon 2015-05-25 17:20 svarrette>
       _   _ _     _   _ ____   ____   ____        _    __ _ _
      | | | | |   | | | |  _ \ / ___| |  _ \  ___ | |_ / _(_) | ___  ___
      | | | | |   | |_| | |_) | |     | | | |/ _ \| __| |_| | |/ _ \/ __|
      | |_| | |___|  _  |  __/| |___  | |_| | (_) | |_|  _| | |  __/\__ \
       \___/|_____|_| |_|_|    \____| |____/ \___/ \__|_| |_|_|\___||___/

         Copyright (c) 2015 UL HPC Management Team <hpc-sysadmins@uni.lu>

# ULHPC dotfiles (bash, vim, screen etc.) 

## Synopsis

This repository offers a set of default configuration files for `bash`, `screen`, `vim` etc. suitable for the [ULHPC](http://hpc.uni.lu) environment, but also for any Linux user wishing a reasonable set of functionality for these software (better than the default one proposed by default). 
For instance, this repository is used in the [ULHPC/bash](https://github.com/ULHPC/puppet-bash) puppet module.

In the sequel, when providing a command, `$>` denotes a prompt and is not part of the commands.

## Pre-requisites

You should install the following elements to use the full functionality of
these config files:

* bash
* bash-completions
* screen
* git
* subversion
* vim

## Installation 

This repository is hosted on [Github](https://github.com/ULHPC/dotfiles).
To install the dotfiles for the current user, you can use the proposed [`install.sh`](install.sh) script directly (assuming  [curl](http://curl.haxx.se/) is available on your system which is normally the case):

      $> bash <(curl --silent https://raw.githubusercontent.com/ULHPC/dotfiles/master/install.sh)

Or you might wish to install it after cloning the repository:

    $> git clone https://github.com/ULHPC/dotfiles.git ~/.dotfiles
    $> ~/.dotfiles/install.sh

You can run `install.sh --help` to see the available options.

_Note_: If the files already exists on your system, a backup `<file>.bak` will be created

## Environment

These config files have been tested on Debian Linux but should work on any other unix-like system, eventually with a little tweaking.

You can use the provided [`Vagrantfile`](http://docs.vagrantup.com/v2/vagrantfile/) to test it safely in a [Vagrant](vagrantup.com/) box (see [installation notes](http://docs.vagrantup.com/v2/installation/)) as follows:

       $> cd /path/to/cloned/dotfiles
	   $> vagrant up
       [...]
	   $> vagrant ssh
	   (vagrant)$> /vagrant/install.sh --dry-run

## Uninstall / Remove ULHPC dotfiles 

The [`install.sh`](install.sh) script supports the `--delete` option to remove the previously installed dotfiles. 

     $> ~/.dotfiles/install.sh --delete

Note that the symlinks will be removed **only if** their target match the corresponding dotfile.

## BUGS

Find a bug? Just post a new issue on [Github](https://github.com/ULHPC/dotfiles/issues)!

## DISCLAIMER

These `dotfiles` are distributed in the hope that they will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

## AUTHOR

[ULHPC Team](https://hpc.uni.lu/about/team.html#system-administrators), using various contributions on the Internet, in particular:

*  [Sebastien Varrette dotfiles](http://github.com/Falkor/dotfiles)
*  [Hyacinthe Cartiaux dotfiles](http://github.com/hcartiaux/dotfiles)
*  [Derek Payton dotfiles](http://bitbucket.org/dmpayton/dotfiles/src/tip/.bashrc)
*  [Ryan Tomayko dotfiles](http://github.com/rtomayko/dotfiles/blob/rtomayko/.bashrc)
*  [Sebastien Badia vim configuration](https://github.com/sbadia/grimvim)

These files are released under [GNU GPL Licence v3](LICENCE).
You may use, modify, and/or redistribute them under the terms of the GPL Licence v3.

## Contributing

That's quite simple:

1. [Fork](https://help.github.com/articles/fork-a-repo/) it. Then once cloned your forked copy of this repository, ensure you have correctly initialize it ([Git-flow](https://github.com/nvie/gitflow), Git [submodules](.gitmodules) etc.  etc.) using: 

          $> make setup

2. Create your own feature branch

          $> git checkout -b my-new-feature

3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new [Pull Request](https://help.github.com/articles/using-pull-requests/)

This assumes that you have understood the branch layout configured for this repository -- see below. 

### [Git-flow](https://github.com/nvie/gitflow)

The Git branching model for this repository follows the guidelines of
[gitflow](http://nvie.com/posts/a-successful-git-branching-model/).
In particular, the central repository holds two main branches with an infinite lifetime:

* `production`: the *production-ready* branch
* `master`: the main branch where the latest developments interviene. This is the *default* branch you get when you clone the repository.

Thus you are more than encouraged to install the [git-flow](https://github.com/nvie/gitflow) extensions following the [installation procedures](https://github.com/nvie/gitflow/wiki/Installation) to take full advantage of the proposed operations. The associated [bash completion](https://github.com/bobthecow/git-flow-completion) might interest you also.

### Releasing mechanism

The operation consisting of releasing a new version of this repository is automated by a set of tasks within the root `Makefile`.

In this context, a version number have the following format:

      <major>.<minor>.<patch>[-b<build>]

where:

* `< major >` corresponds to the major version number
* `< minor >` corresponds to the minor version number
* `< patch >` corresponds to the patching version number
* (eventually) `< build >` states the build number _i.e._ the total number of commits within the `master` branch.

Example: \`1.0.0-b28\`

The current version number is stored in the root file `VERSION`. __/!\ NEVER MAKE ANY MANUAL CHANGES TO THIS FILE__

For more information on the version, run:

     $> make versioninfo

If a new version number such be bumped, you simply have to run:

      $> make start_bump_{major,minor,patch}

This will start the release process for you using `git-flow`.
Once you have finished to commit your last changes, make the release effective by running:

      $> make release

it will finish the release using `git-flow`, create the appropriate tag in the `production` branch and merge all things the way they should be.


