# zsh-histsync

oh-my-zsh plugin for syncing ZSH history.

Synchronizes history between multiple machines using a git repository.

## Setup


Create a git repository, or clone one in the location your history will be kept. The default location is ```${ZSH_CUSTOM}/zsh-history/```. This expands to ```${HOME}/.oh-my-zsh/custom/``` by default, but can be changed in the ```zshrc```.

To override the default location, add ```export ZSH_HISTSYNC_REPO=<desired location>``` in your ```zshrc``` configuration file.

## Usage
