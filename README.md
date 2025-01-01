# dotfiles

My Dotfiles setup

Checkout [Jake Wiesler's guide](https://www.jakewiesler.com/blog/managing-dotfiles) on using [Stow](https://www.gnu.org/software/stow/) with Dotfiles to create your symlinks automatically.

## Installation

```sh
brew install stow
```

## Adding symlink ZSH (note it's the folder name)

```sh
stow zsh
```

## Adding symlink GIT

```sh
stow git
```

## Refresh terminal

```sh
exec $SHELL
```
