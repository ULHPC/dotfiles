-*- mode: markdown; mode: visual-line; fill-column: 80 -*-

[![Licence](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](http://www.gnu.org/licenses/gpl-3.0.html) ![By ULHPC](https://img.shields.io/badge/by-ULHPC-blue.svg)  [![Build Status](https://travis-ci.org/ULHPC/dotfiles.svg?branch=feature/falkor_import)](https://travis-ci.org/ULHPC/dotfiles) [![github](https://img.shields.io/badge/git-github- lightgray.svg)](https://github.com/ULHPC/dotfiles) [![ULHPC/dotfiles issues](https://img.shields.io/github/issues/ULHPC/dotfiles.svg)](https://github.com/ULHPC/dotfiles/issues) ![](https://img.shields.io/github/stars/ULHPC/dotfiles.svg) [![Documentation Status](https://readthedocs.org/projects/ulhpc-dotfiles/badge/?version=latest)](https://readthedocs.org/projects/ulhpc-dotfiles/?badge=latest)

      Time-stamp: <Mon 2015-05-25 17:20 svarrette>
       _   _ _     _   _ ____   ____   ____        _    __ _ _
      | | | | |   | | | |  _ \ / ___| |  _ \  ___ | |_ / _(_) | ___  ___
      | | | | |   | |_| | |_) | |     | | | |/ _ \| __| |_| | |/ _ \/ __|
      | |_| | |___|  _  |  __/| |___  | |_| | (_) | |_|  _| | |  __/\__ \
       \___/|_____|_| |_|_|    \____| |____/ \___/ \__|_| |_|_|\___||___/

         Copyright (c) 2013-2016 UL HPC Management Team <hpc-sysadmins@uni.lu>

# ULHPC dotfiles (bash, vim, screen etc.) 

## Synopsis

This repository offers a set of default configuration files for `bash`, `screen`, `vim` etc. suitable for the [ULHPC](http://hpc.uni.lu) environment, but also for any Linux user wishing a reasonable set of functionality for these software (better than the default one proposed by default). 
For instance, this repository is used in the [ULHPC/bash](https://github.com/ULHPC/puppet-bash) puppet module.

In the sequel, when providing a command, `$>` denotes a prompt and is not part of the commands.

## Pre-requisites

You should install the following elements to use the full functionality of
these configuration files:

* bash
* bash-completions
* screen
* git
* subversion
* vim


## Installation

### All-in-one git-free install

Using `curl` (adapt the `--all` option to whatever you prefer -- see below table):

``` bash
$> curl -fsSL https://raw.githubusercontent.com/ULHPC/dotfiles/master/install.sh | bash -s -- --all
```

### Using Git and the embedded Makefile

This repository is hosted on [Github](https://github.com/ULHPC/dotfiles). You can clone the repository wherever you want.
If the location of the local repository is not `~/.dotfiles`, the `install.sh` script will create a symlink `~/.dotfiles` pointing to the location of the repository.

To clone this repository directly into `~/.dotfiles/`, proceed as follows

        $> git clone https://github.com/ULHPC/dotfiles.git ~/.dotfiles

**`/!\ IMPORTANT`**: Once cloned, initiate your local copy of the repository by running:

        $> cd ~/.dotfiles
        $> make setup

This will initiate the [Git submodules of this repository](.gitmodules) and setup the [git flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) layout for this repository.

Now to install all the dotfiles, run:

~~~bash
    $> make install
~~~

### Using Git and the embedded `install.sh` script

The above `make install` command actually runs (see `.Makefile.after`):

~~~bash
     $> ./install.sh --all   # Equivalent of 'make install'
~~~

Note that __by default__ (_i.e._ without option), the `install.sh` script does nothing __except__ cloning the ULHPC/dotfilesirectory if it does not yet exists (in `~/.dotfiles` by default).

* if you __do not want to install everything__ but only a subpart, kindly refer to the below table to find the proper command-line argument to use. Ex:

```bash
         $> ./install.sh --vim --git
```

* if you want to install everything in a row, use as suggested above the `--all` option


## Updating / Upgrading

Upgrading is normally as simple as:

     $> make -C ~/.dotfiles update

OR, if you prefer a more atomic approach:

     $> cd ~/.dotfiles
     $> make update

Note that if you wish to __upgrade__ the [Git submodules](.gitmodules) to the latest version, you should run:

     $> make upgrade

## Uninstalling / Removing the ULHPC dotfiles

You can use `install.sh --delete` to remove the ULHPC dotfiles.

__`/!\ IMPORTANT`__: pay attention to use the options matching you installation package.

* if you have installed __all__ the dotfiles, run:

```bash
     $> ./install.sh --delete --all     # OR make uninstall
```

* if you have installed __only__ a subpart of the dotfiles, adapt the command line option. Ex:

```bash
     $> ./install.sh --delete --vim --git
```


## What's included and how to customize?

| Tools                                                                          | Type                  | Installation            | Documentation                                |
|--------------------------------------------------------------------------------|-----------------------|-------------------------|----------------------------------------------|
| [Bourne-Again shell (bash)](http://tiswww.case.edu/php/chet/bash/bashtop.html) | shell                 | `./install.sh --bash`   | [`bash/README.md`](bash/README.md)           |
| [VI iMproved (vim)](http://www.vim.org/)                                       | editor                | `./install.sh --vim`    | [`vim/README.md`](vim/README.md)             |
| [Git `--fast-version-control`](https://git-scm.com/)                           | VCS                   | `./install.sh --git`    | [`git/README.md`](git/README.md)             |
| [GNU screen](https://www.gnu.org/software/screen/)                             | terminal multiplexers | `./install.sh --screen` | [`screen/README.md`](screen/README.md)       |
| [SSH](http://www.openssh.com/)                                                 | remote shell          | `./install.sh --ssh`    | [`ssh/README.md`](ssh/README.md)       |
|                                                                                |                       |                         |                                              |

As mentioned above, if you want to install all dotfiles in one shot, just use

      $> ./install.sh --all      # OR 'make install'

## Issues / Feature request

You can submit bug / issues / feature request using the [`ULHPC/dotfiles` Project Tracker](https://github.com/ULHPC/dotfiles/issues) or the [UL HPC Tracker](https://hpc-tracker.uni.lu).

## Developments / Contributing to the code

If you want to contribute to the code, you shall be aware of the way this repository is organized and developed.
These elements are detailed on `docs/contributing/`

## Licence

This project is released under the terms of the [GPL-3.0](LICENCE) licence.

[![Licence](https://www.gnu.org/graphics/gplv3-88x31.png)](http://www.gnu.org/licenses/gpl-3.0.html)

## Resources

We have created this repository using various contributions on the Internet, in particular:

* [Your unofficial guide to dotfiles on GitHub](https://dotfiles.github.io/)
* [S.Varrette's dotfiles](https://github.com/Falkor/dotfiles)
* [H.Cartiaux's dotfiles](https://github.com/hcartiaux/dotfiles)
* [Holman's does dotfiles](https://github.com/holman/dotfiles), for his idea of bundling the [homebrew](http://brew.sh) configuration
* [Mathias’s dotfiles](https://github.com/mathiasbynens/dotfiles),  for featuring `~/.osx` _i.e._ sensible hacker defaults for OS X;
* [Awesome dotfiles](https://github.com/webpro/awesome-dotfiles), a curated list of dotfiles resources. Inspired by the [awesome](https://github.com/sindresorhus/awesome) list thing.
* [Carlo's dotfiles](https://github.com/caarlos0/dotfiles)


