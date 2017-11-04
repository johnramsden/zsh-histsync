# zsh-histsync

oh-my-zsh plugin for syncing ZSH history.

Synchronizes history between multiple machines using a git repository.

## Setup

Create a git repository, or clone one in the location your history will be kept.

The default location is ```${ZSH_CUSTOM}/zsh-history/```. This will depend on where your ```${ZSH_CUSTOM}``` directory is, it is located at ```${HOME}/.oh-my-zsh/custom/``` by default, but can be changed in the ```zshrc```.

```
cd ${ZSH_CUSTOM}
git init zsh-history
```

Add a remote location where history will be kept, and copy in your history you want to start with. alternatively, create a blank file to start with empty history.

```
git remote add origin git@github.com:johnramsden/zsh-history.git
cp ${HOME}/.zsh_history zsh_history
git add zsh_history
```

With the history configured, clone the plugin in your oh-my-zsh plugin directory.

```
cd ${ZSH_CUSTOM}/plugins
git clone git@github.com:johnramsden/zsh-history.git
```

Now add the plugin to your zshrc active plugins, it should be added as 'histsync'.

```
plugins=(git archlinux ... histsync)
```

## Options

To override the default options, export the associated variable in your ```zshrc``` configuration file.

*   ```ZSH_HISTSYNC_FILE_NAME=zsh_history```           - Default settings, overrride in zshrc
*   ```ZSH_HISTSYNC_REPO=${ZSH_CUSTOM}/zsh-history```  - Set zsh histsync repo location
*   ```GIT_COMMIT_MSG="History update from $(hostname) - $(date)"```  - Set commit message

## Usage

The ```histsync``` command is used to manage the history synchronization.

The following commands exist:

*   ```histsync```
*   ```histsync clone```
*   ```histsync commit <repository>```
*   ```histsync help```
*   ```histsync pull```
*   ```histsync push```

### Main Command

Command    | Description
-----------|---
histsync   | Merge local history with remote, and push resulting history

### Subcommands

Subcommands can be used to do individual steps on the repository.

Format: ```histsync [subcommand]```

Command                 | Description
------------------------|---
```clone <repository>```      | Clone a repository to ```ZSH_HISTSYNC_REPO```
```commit```                  | Commit the current history file
```help```                    | Print usage information
```pull```                    | Pull from remote and merge current history
```push```                    | Push committed history to remote

### Variables

To override the default options, export the associated variable in your ```zshrc```

Variable                 | Description
------------------------|---
```ZSH_HISTSYNC_FILE_NAME```  | Name to save history as in repository
```ZSH_HISTSYNC_REPO```       | zsh histsync repo location
```GIT_COMMIT_MSG```          | Commit message
