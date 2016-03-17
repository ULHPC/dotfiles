# ULHPC Dotfiles -- Bourne-Again Shell (bash) configuration

## Installation

You can use the `install.sh` script featured with the [ULHPC dotfiles](https://github.com/ULHPC/dotfiles) repository.

``` bash
$> cd ~/.dotfiles
$> ./install.sh --bash     # OR ./install.sh --with-bash
```
This will setup the following files:

* `~/.bashrc`
* `~/.inputrc`
* `~/.profile`
* `~/.bash_profile`
* `~/.bash_logout`
* `~/.bash_aliases`

## Uninstall

``` bash
$> cd ~/.dotfiles
$> ./install.sh --delete --bash
```

## Customizations

Use the `~/.bash_private` as a place holder for your own customization. This file is loaded by the `.bashrc` file.
