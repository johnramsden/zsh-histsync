###
# John Ramsden
# johnramsden @ github
# Version 0.1.1
###

autoload -U colors
colors

## Settings ##
# The following variables can be exported in your zshrc to override the defaults:

ZSH_HISTSYNC_FILE_NAME=zsh_history           # Default settings, overrride in zshrc
ZSH_HISTSYNC_REPO=${ZSH_CUSTOM}/zsh-history  # Set zsh histsync repo location
GIT_COMMIT_MSG="Histsync $(hostname) - $(date)"  # Set commit message

## Local variables and functions

local ZSH_HISTSYNC_FILE=${ZSH_HISTSYNC_REPO}/${ZSH_HISTSYNC_FILE_NAME}

function histsync_help_output() {
  printf "%-25s | %-50s\n" "  ${1}" "${2}"
}

function histsync_usage() {
  echo "histsync usage"
  echo
  echo "-------------------------------------------------------------"
  echo "  histsync [subcommand]"
  echo
  echo "-------------------------------------------------------------"
  echo "Main command:"
  histsync_help_output "histsync" "Merge local history with remote, and push resulting history"
  echo
  echo "-------------------------------------------------------------"
  echo "Sub commands:"
  histsync_help_output "clone <repository>" "Clone a repository to ZSH_HISTSYNC_REPO"
  histsync_help_output "commit" "Commit the current history file"
  histsync_help_output "help"   "Print usage information"
  histsync_help_output "pull"   "Pull from remote and merge current history"
  histsync_help_output "push"   "Push committed history to remote"

  echo
  echo "-------------------------------------------------------------"
  echo "To override the default options, export the associated variable in your zshrc"
  echo
  histsync_help_output "ZSH_HISTSYNC_FILE_NAME" "Name to save history as in repository"
  histsync_help_output 'ZSH_HISTSYNC_REPO'      "zsh histsync repo location"
  histsync_help_output 'GIT_COMMIT_MSG'         "Commit message"

  echo

  return 0;
}

# Pull current master and merge with zsh_history
function histsync_pull() {
  local DIR=${CWD}

  # Pull
  cd ${ZSH_HISTSYNC_REPO} && git pull
  if [[ ${?} != 0 ]]; then
    echo "${bold_color}${fg[red]}Failed to pull from git repo...${reset_color}";
    cd ${DIR}
    return 1
  fi

  # Merge
  cat ${HISTFILE} ${ZSH_HISTSYNC_FILE_NAME} | awk '/:[0-9]/ { if(s) { print s } s=$0 } !/:[0-9]/ { s=s""$0 } END { print s }' | sort -u > "${ZSH_HISTSYNC_FILE}.merged"
  local MERGE_SUCCESS=${?}
  cd ${DIR}

  if [[ ${MERGE_SUCCESS} != 0 ]]; then
    echo "${bold_color}${fg[red]}Failed to merge histories...${reset_color}";
    return 1
  fi

  # Backup
  echo "Backing up old history and applying new merged history"
  cp --backup=simple "${ZSH_HISTSYNC_FILE}.merged" "${HISTFILE}"
  rm "${ZSH_HISTSYNC_FILE}.merged"

  local BACKUP_SUCCESS=${?}
  cd ${DIR}

  if [[ ${BACKUP_SUCCESS} != 0 ]]; then
    echo "${bold_color}${fg[red]}Failed to backup and apply history...${reset_color}";
    return 1
  fi

  return 0
}

function histsync_commit() {
  echo "${bold_color}${fg[yellow]}Committing current local history file. ${reset_color}"
  local DIR=${CWD}
  cd ${ZSH_HISTSYNC_REPO}

  cp --backup=simple "${HISTFILE}" "${ZSH_HISTSYNC_FILE_NAME}"
  local BACKUP_SUCCESS=${?}

  git add "${ZSH_HISTSYNC_FILE_NAME}" && git commit -m "${GIT_COMMIT_MSG}"
  local COMMIT_SUCCESS=${?}

  cd ${DIR}

  if [[ ${COMMIT_SUCCESS} != 0 ]]; then
    echo "${bold_color}${fg[red]}Failed to commit to git repo...${reset_color}";
    return 1
  elif [[ ${BACKUP_SUCCESS} != 0 ]]; then
    echo "${bold_color}${fg[red]}Failed backup and commit history...${reset_color}";
    cd ${DIR}
    return 1
  fi

  return 0
}

# Push current history to remote
function histsync_push() {

  echo "${bold_color}${fg[yellow]}Pushing to remote ${reset_color}"
  DIR=${CWD}

  cd ${ZSH_HISTSYNC_REPO} && git push

  local PUSH_SUCCESS=${?}
  cd ${DIR}

  if [[ ${PUSH_SUCCESS} != 0 ]]; then
    echo "${bold_color}${fg[red]}Failed to push to git repo...${reset_color}";
    return 1
  fi
  return 0
}

function histsync_clone() {
  echo "${bold_color}${fg[yellow]}Cloning remote repo ""'""${1}""'""...${reset_color}"

  if [ -d "${ZSH_HISTSYNC_REPO}" ]; then
    echo "${bold_color}${fg[red]}Directory ""'""${ZSH_HISTSYNC_REPO}""'"" already exists.${reset_color}";
    return 1
  fi

  git clone "${1}" "${ZSH_HISTSYNC_REPO}"

  if [[ ${?} != 0 ]]; then
    echo "${bold_color}${fg[red]}Failed to clone git repo...${reset_color}";
    return 1
  fi
  return 0
}

function histsync_sync() {
  histsync_pull
  if [[ ${?} != 0 ]]; then
    echo "${bold_color}${fg[red]}Failed to pull from git repo...${reset_color}";
    return 1
  fi

  histsync_commit
  if [[ ${?} != 0 ]]; then
    echo "${bold_color}${fg[red]}Failed commit to git repo...${reset_color}";
    return 1
  fi

  histsync_push
  if [[ ${?} != 0 ]]; then
    echo "${bold_color}${fg[red]}Failed to push to git repo...${reset_color}";
    return 1
  fi

  return 0
}

function histsync() {
  command="${1:-sync}"

  case ${command} in
    clone )
      histsync_clone "${2}"
      ;;
    commit )
      histsync_commit
      ;;
    pull )
      histsync_pull
      ;;
    push )
      histsync_push
      ;;
    sync )
      histsync_sync
      ;;
    * )
      histsync_usage
      ;;
  esac
}
