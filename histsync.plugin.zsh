###
# John Ramsden
# johnramsden @ github
###

autoload -U colors
colors

# Default settings, overrride in zshrc
ZSH_HISTSYNC_FILE_NAME=zsh_history

# Set zsh histsync location to XDG config directory if set
ZSH_HISTSYNC_REPO=${ZSH_CUSTOM}/zsh-history

ZSH_HISTSYNC_FILE=${ZSH_HISTSYNC_REPO}/${ZSH_HISTSYNC_FILE_NAME}

GIT_COMMIT_MSG="History update from $(hostname) - $(date)"

function histsync_usage() {
    echo "${bold_color}${fg[red]}Usage:${reset_color}" 1>&2;

    echo "histsync"
    echo "histsync clone"
    echo "histsync commit <repository>"
    echo "histsync help"
    echo "histsync pull"
    echo "histsync push"

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
  histsync_commit && histsync_pull && histsync_push

  local SYNC_SUCCESS=${?}
  cd ${DIR}

  if [[ ${SYNC_SUCCESS} != 0 ]]; then
      echo "${bold_color}${fg[red]}Failed to sync git repo...${reset_color}";
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
