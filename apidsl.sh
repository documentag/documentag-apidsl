#!/bin/bash
# Locally installed software must be placed within /usr/local rather than /usr unless it is being installed to replace or upgrade software in /usr.
# https://github.com/apidsl/download

# CONTRIBUTION
## Author: Tom Sapletta
## Created Date: 23.05.2022

## USAGE:
# ./apidsl.sh -h
# ./apidsl.sh --help
# apidsl example2.txt
# apidsl example/example3.txt
# apidsl "http("https://www.rezydent.de/").xpath("title")"

## PARAMS
CMD=$1
OPTION=$CMD
(($# == 2)) && CMD=$2 && OPTION=$1
[ -z "$CMD" ] && CMD="-h"


#[ $# -ne 1 ] && echo "Exactly 1 param is needed" &&  exit 1

MODULE="apidsl"
VER="0.2"
FILE_EXT=".txt"
CMD_EXT=".sh"
CONFIG_FILE=".${MODULE}"
CONFIG_DEFAULT="${MODULE}${FILE_EXT}"
CONFIG_DEV="${MODULE}.dev${FILE_EXT}"
CONFIG_TEST="${MODULE}.test${FILE_EXT}"
INPUT_FOLDER=".${MODULE}"
COMMAND_LANGUAGE="bash"
CACHE_FOLDER=".${MODULE}.cache"
HISTORY_FOLDER=".${MODULE}.history"
FTIME="$(date +%s)"
INPUT_FILETIME="${CACHE_FOLDER}/${FTIME}"
CACHE_FILE="${INPUT_FILETIME}.cache${FILE_EXT}"
LOGS="${INPUT_FILETIME}.logs${FILE_EXT}"
CURRENT_FOLDER=$(pwd)

# show last logs
if (($# == 1)); then
  if [ "$OPTION" == "-l" ] || [ "$OPTION" == "--logs" ]; then
    ## -A list all files except . and ..
    ## -r reverse order while sorting
    ## -t sort by time, newest first
    LOGS=$(cd $CACHE_FOLDER && ls -Art | tail -n 1)
    LOGS="$CACHE_FOLDER/$LOGS"
    echo -e "\n\nLOGS ($LOGS):"
    cat $LOGS

    CACHE_FILE=${LOGS/logs/cache/}
    echo -e "\n\nCOMMANDS ($CACHE_FILE):"
    cat $CACHE_FILE

    BASH_FILE=${LOGS/logs.txt/sh/}
    echo -e "\n\nSCRIPTS ($BASH_FILE):"
    cat $BASH_FILE
    exit
  fi
fi


# PARSER CONFIG ######################################
#Create temporary file with new line in place
#cat $CMD | sed -e "s/)/\n/" > $CACHE_FILE
DSL_HASH="#"
DSL_SLASHSLASH='//'
DSL_SLASHSLASHSLASH='.///'
DSL_DOT="."
DSL_SEMICOLON=";"
DSL_LEFT_BRACE="("
DSL_RIGHT_BRACE=")"
DSL_RIGHT_BRACE_SEMICOLON=");"
DSL_RIGHT_BRACE_DOT=")."
DSL_NEW="\n"
DSL_EMPTY=""
DSL_LOOP="forEachLine"
### PARSER CONFIG ######################################
#CMD="${CMD%/}"
#echo $CMD
#echo ${@%/}
#echo ${CMD%*${var#*/*/*/}}
#exit
#[ "$CMD" == ${DSL_SLASHSLASHSLASH} ] && echo "!!! FILE ${CMD} NOT EXIST "
#[ "$CMD" == "/" ] && echo "!!! FILE ${CMD} NOT EXIST " >>$LOGS && exit
#[ "$CMD" == "./" ] && echo "!!! FILE ${CMD} NOT EXIST " >>$LOGS && exit

# PREPARE NUMBER for LOGS
echo -n "$FTIME" >"$CONFIG_FILE"

# START
mkdir -p "$CACHE_FOLDER"
echo "$(date +"%T.%3N") START" >$LOGS

echo "CMD $CMD" >>$LOGS
echo "OPTION $OPTION" >>$LOGS

# VERSION   ######################################
if [ "$OPTION" == "-v" ] || [ "$OPTION" == "--version" ]; then
  echo "$MODULE v $VER"
  exit
fi
# HELP INFO ######################################
if [ "$OPTION" == "-h" ] || [ "$OPTION" == "--help" ]; then
  echo "$MODULE $VER"
  echo "OPERATOR or COMMAND is needed!"
  echo "# OPERATORS:"
  echo "$MODULE dev - development packages, for contributors and developers"
  echo "$MODULE test - for testing the project"
  echo "$MODULE --version - show modulname and version"
  echo "$MODULE --get - get require dependency files apidsl script from file"
  echo "$MODULE --run - run apidsl script from file"
  echo "$MODULE --clean - clean cache data"
  echo "$MODULE --help - how to use apidsl"
  echo "$MODULE --history - show logs during runnig"
  echo "$MODULE --logs - show logs during runnig"
  #echo "$MODULE --logs - show logs after run"
  echo "$MODULE --init - copy command apidsl.sh to /usrl/local/bin to use apidsl such a system command in shell"
  echo "  $MODULE --init apidsl - with 2 params: copy command apidsl to /usrl/local/bin to use apidsl such a system command in shell"
  echo "$MODULE --download - download from repository and save as apidsl file"
  echo "# USAGE COMMAND:"
  echo "$MODULE 'get(\"https://github.com/letpath/bash\",\"path\")' - import project from git"
  echo "$MODULE 'path.load(\"flatedit.txt\")' - use imported command, such load file "
  exit
fi
### HELP INFO ######################################

# CONFIG FILE ######################################
if [ "$OPTION" == "init" ]; then
  echo -n "$CONFIG_DEFAULT" >"$CURRENT_FOLDER/$CONFIG_FILE"
  exit
fi
if [ "$OPTION" == "dev" ]; then
  echo -n "$CONFIG_DEV" >"$CURRENT_FOLDER/$CONFIG_FILE"
  exit
fi
if [ "$OPTION" == "test" ]; then
  echo -n "$CONFIG_TEST" >"$CURRENT_FOLDER/$CONFIG_FILE"
  exit
fi

if [ "$OPTION" == "-d" ] || [ "$OPTION" == "--download" ]; then
  FILE_TO_INSTALL=$2
  [ -z "$FILE_TO_INSTALL" ] && FILE_TO_INSTALL=apidsl.sh
  curl https://raw.githubusercontent.com/apidsl/download/main/apidsl.sh -o $FILE_TO_INSTALL
  exit
fi

if [ "$OPTION" == "-i" ] || [ "$OPTION" == "--init" ]; then
  FILE_TO_INSTALL=$2
  [ -z "$FILE_TO_INSTALL" ] && FILE_TO_INSTALL=apidsl.sh
  sudo cp -f $FILE_TO_INSTALL /usr/local/bin/apidsl
  exit
fi

if [ "$OPTION" == "-c" ] || [ "$OPTION" == "--clean" ]; then
  rm -rf "${CURRENT_FOLDER}/${CACHE_FOLDER}/"
  exit
fi


if [ "$OPTION" == "-h" ] || [ "$OPTION" == "--history" ]; then
  # get latest logs ID
  FTIME_LOGS=$(cat "$CONFIG_FILE")
  # Prepare Path based on latest logs ID
  INPUT_FILETIME_LOGS="${CACHE_FOLDER}/${FTIME_LOGS}"
  LOGS_FILE="${INPUT_FILETIME_LOGS}.logs${FILE_EXT}"
  CACHE_FILE="${INPUT_FILETIME_LOGS}.cache${FILE_EXT}"
  # Print script and logs
  echo -e "SCRIPTS:"
  cat $CACHE_FILE
  echo -e "\nLOGS:"
  cat $LOGS_FILE
  exit
fi

PROJECT_LIST=$2
[ -z "$PROJECT_LIST" ] && [ -f "$CONFIG_FILE" ] && PROJECT_LIST=$(cat "$CONFIG_FILE")
[ -z "$PROJECT_LIST" ] && PROJECT_LIST="$CONFIG_DEFAULT"
[ ! -f "$PROJECT_LIST" ] && echo -n "" >"$CONFIG_DEFAULT" && echo "$LOGS" >>".gitignore"
### CONFIG FILE ######################################
INPUT_FILE_PATH="${INPUT_FILETIME}${FILE_EXT}"
BASH_FILE="${INPUT_FILETIME}${CMD_EXT}"
BASH_LOOP_FILE="${INPUT_FILETIME}.loop${CMD_EXT}"


# IMPORT COMMAND ##########################
#cd "${CURRENT_FOLDER}"
if [ "$OPTION" == "-g" ] || [ "$OPTION" == "--get" ]; then

  # FROM COMMMAND
  if (($# == 3)); then
    #&& filename=$3 && CMD=$2 && OPTION=$1
    git_repo=(${2})
    git_folder=(${3})
    #echo "$git_repo $git_folder"
    #exit
    git_folder="${git_folder%\"}"
    git_folder="${git_folder#\"}"
    [ -d ${git_folder} ] && echo "!!! FOLDER ${git_folder} EXIST, PLEASE INSTALL IN ANOTHER FOLDER " >>$LOGS && continue
    #todo: replace git@github.com:
    git clone $git_repo $git_folder && cd $git_folder
    [ "$(pwd)" == "$CURRENT_FOLDER" ] && echo "!!! GIT PROJECT ${git_repo} NOT EXIST, PLEASE INSTALL FIRST " >>$LOGS && continue
    [ -f ".gitignore" ] && echo "${git_folder}" >>.gitignore
    [ -f "composer.json" ] && ${BUILD_PHP}
    [ -f "package.json" ] && ${BUILD_NODEJS}
    exit
  fi
  # FROM FILE
  filename=(${CMD})
  [ ! -f ${filename} ] && echo "!!! FILE/FOLDER ${filename} NOT EXIST, PLEASE INSTALL IN ANOTHER FOLDER " >>$LOGS && exit
  while
    LINE=
    IFS=$' \t\r\n' read -r LINE || [[ $LINE ]]
  do
    [ -z "$LINE" ] && echo "REMOVED: $LINE" >>$LOGS && continue
    #echo "${line:0:1}"
    # Remove Comments
    [ "${LINE:0:1}" == "${DSL_HASH}" ] && continue
    [ "${LINE:0:1}" == "${DSL_SLASHSLASH}" ] && continue
    IFS=' ' read -a repo <<<"$LINE"
    git_repo=(${repo[0]})
    git_folder=(${repo[1]})
    git_folder="${git_folder%\"}"
    git_folder="${git_folder#\"}"
    [ -d ${git_folder} ] && echo "!!! FOLDER ${git_folder} EXIST, PLEASE INSTALL IN ANOTHER FOLDER " >>$LOGS && continue
    git clone $git_repo $git_folder && cd $git_folder
    [ "$(pwd)" == "$CURRENT_FOLDER" ] && echo "!!! GIT PROJECT ${git_repo} NOT EXIST, PLEASE INSTALL FIRST " >>$LOGS && continue
    [ -f ".gitignore" ] && echo "${git_folder}" >>.gitignore
    [ -f "composer.json" ] && ${BUILD_PHP}
    [ -f "package.json" ] && ${BUILD_NODEJS}
  done <"$filename"
  exit
fi

# RUN COMMAND ##########################
if [ "$OPTION" == "-r" ] || [ "$OPTION" == "--run" ]; then
  filename=(${CMD})
  filename="${filename%\"}"
  filename="${filename#\"}"
  #echo "!!! FILE/FOLDER ${filename} NOT EXIST, PLEASE INSTALL IN ANOTHER FOLDER "
  #exit
  [ ! -f ${filename} ] && echo "!!! FILE/FOLDER ${filename} NOT EXIST, PLEASE INSTALL IN ANOTHER FOLDER " >>$LOGS && exit
  cp $filename ${INPUT_FILE_PATH}
else
  echo "${CMD}" >${INPUT_FILE_PATH}
fi

[ ! -f "$INPUT_FILE_PATH" ] && echo "$INPUT_FILE_PATH not exist" >>$LOGS && exit
echo "#!/bin/bash" >$BASH_FILE

echo "INPUT_FILE_PATH $INPUT_FILE_PATH" >>$LOGS
cat $INPUT_FILE_PATH >>$LOGS


# REMOVE COMMENTS ######################################
echo -n "" >$CACHE_FILE
while
  LINE=
  IFS=$' \t\r\n' read -r LINE || [[ $LINE ]]
do
  [ -z "$LINE" ] && echo "REMOVED: $LINE" >>$LOGS && continue
  #echo "${line:0:1}"
  # Remove Comments
  [ "${LINE:0:1}" == "${DSL_HASH}" ] && continue
  [ "${LINE:0:1}" == "${DSL_SLASHSLASH}" ] && continue
  echo "${LINE}" >>$CACHE_FILE
done <"$INPUT_FILE_PATH"

sed -i "s/${DSL_RIGHT_BRACE_DOT}/${DSL_NEW}/g" $CACHE_FILE
sed -i "s/${DSL_RIGHT_BRACE}/${DSL_NEW}/g" $CACHE_FILE
### REMOVE COMMENTS ######################################

# PREPARE functions ######################################
# array to hold all lines read
functions=()
values=()
#while IFS= read -r LINE; do
while
  LINE=
  IFS=$' \t\r\n' read -r LINE || [[ $LINE ]]
do
  #LINE=($line)
  echo "LINE BEFORE CLEANING: $LINE" >>$LOGS
  [ -z "$LINE" ] && continue
  ### SPLIT BY BRACE ##################################
  IFS="$DSL_LEFT_BRACE"
  read -ra line <<<"$LINE"
  #echo "LINE: $line"
  index=0
  key=""

  for i in "${line[@]}"; do
    index=$((index + 1))
    i="$(echo -e "${i}" | tr -d '[:space:]')"

    if [ $index -gt 2 ]; then
      echo $index "break"
    #  break
    fi

    if [ $index == 1 ]; then
      key=$i
    fi
  done
  echo " KEY: $key" >>$LOGS
  echo " VAL: $i" >>$LOGS

  ## depends param function exist or not
  [ "$key" = "$i" ] && functions+=("$key") && values+=("")
  [ "$key" != "$i" ] && functions+=("$key") && values+=("$i")
done <"$CACHE_FILE"
### PREPARE functions ######################################

BUILD_PHP="composer update"
BUILD_NODEJS="npm update"
BUILD_PYTHON="python"
length=${#functions[@]}
loop=
loop_functions=()
loop_values=()
k=0
key=""
value=""
for ((i = 0; i < ${length}; i++)); do
  echo " F$i: ${functions[$i]}" >>$LOGS
  echo " V$i: ${values[$i]}" >>$LOGS
  # Replace dot to slash for path at installed packages
  #key="${functions[$i]/./\/}"
  key="${functions[$i]}"
  value="${values[$i]}"

  # IMPORT COMMAND ##########################
  # install dependencies by apifork
  cd "${CURRENT_FOLDER}"
  if [ "$key" == "get" ]; then
    #[ ! -z "${keys[1]}" ] && CMD_FILE_NAME=${keys[1]} && CMD_FOLDER_NAME=/${keys[0]}
    IFS=',' read -a repo <<<"$value"
    git_repo=(${repo[0]})
    git_folder=(${repo[1]})
    git_folder="${git_folder%\"}"
    git_folder="${git_folder#\"}"
    [ -d ${git_folder} ] && echo "!!! FOLDER ${git_folder} EXIST, PLEASE INSTALL IN ANOTHER FOLDER " >>$LOGS && continue
    git clone $git_repo $git_folder && cd $git_folder
    echo "git clone $git_repo $git_folder"  >>$LOGS
    [ "$(pwd)" == "$CURRENT_FOLDER" ] && echo "!!! GIT PROJECT ${git_repo} NOT EXIST, PLEASE INSTALL FIRST " >>$LOGS && continue
    [ -f ".gitignore" ] && echo "${git_folder}" >>.gitignore
    [ -f "composer.json" ] && ${BUILD_PHP}
    [ -f "package.json" ] && ${BUILD_NODEJS}
    continue
  fi
  ### IMPORT COMMAND ##########################

  # RUN COMMAND ##########################
  if [ "$key" == "run" ]; then
    filename=(${value})
    filename="${filename%\"}"
    filename="${filename#\"}"
    #echo $filename
    echo "RUN SELF apidsl --run ${filename} " >>$LOGS
    apidsl --run ${value}
    #[ ! -f "${filename}" ] && echo "!!! FILE/FOLDER ${filename} NOT EXIST, PLEASE INSTALL IN ANOTHER FOLDER " && continue
    exit
  fi
  ### RUN COMMAND ##########################

  #k=$((k+1))
  IFS='.' read -a keys <<<"$key"
  #value="${values[$i]}"
  CMD_FILE_NAME=$key
  CMD_FOLDER_NAME=
  echo "ADD COMMAND $i: $key $value" >>$LOGS
  [ ! -z "${keys[1]}" ] && CMD_FILE_NAME=${keys[1]} && CMD_FOLDER_NAME=/${keys[0]}
  [ "$key" == "split" ] && loop="1"
  #[ "$key" == "filesRecursive" ] && loop="1"
  if [ -z "$loop" ]; then
    COMMAND_VALUE=".${CMD_FOLDER_NAME}/${CMD_FILE_NAME}.sh $value"
    echo -n "$COMMAND_VALUE" >>$BASH_FILE
    #    echo -n " && cd $CURRENT_FOLDER " >>$BASH_FILE
    echo -n " | " >>$BASH_FILE
    echo "ADD SCRIPT $i: $COMMAND_VALUE TO FILE: $BASH_FILE" >>$LOGS
  else
    loop_functions+=("$key")
    loop_values+=("$value")
    echo "ADD KEY: $key TO ARRAY LOOP" >>$LOGS
  fi
done

## LOOP ##########################
## LOOP with split function
## TODO: more loop options
## TODO: many loop in one sentence
if [ ! -z "$loop" ]; then
  #echo $BASH_LOOP_FILE
  echo -n "./$BASH_LOOP_FILE " >>$BASH_FILE

  echo "#!/bin/bash" >$BASH_LOOP_FILE
  echo "IFS='' read -d '' -r list" >>$BASH_LOOP_FILE
  echo 'while IFS= read -r ITEM; do' >>$BASH_LOOP_FILE
  #echo ' echo "$ITEM"' >>$BASH_LOOP_FILE

  length=${#loop_functions[@]}
  first=1
  for ((i = 0; i < ${length}; i++)); do

    #echo "${loop_functions[$i]}"
    #echo "${loop_values[$i]}"
    key="${loop_functions[$i]}"
    IFS='.' read -a keys <<<"$key"
    value="${loop_values[$i]}"
    CMD_FILE_NAME=$key
    CMD_FOLDER_NAME=
    [ ! -z "${keys[1]}" ] && CMD_FILE_NAME=${keys[1]} && CMD_FOLDER_NAME=/${keys[0]}

    if [ -z "$first" ]; then
      echo -n ".${CMD_FOLDER_NAME}/${CMD_FILE_NAME}.sh $value" >>$BASH_LOOP_FILE
      echo -n ' | ' >>$BASH_LOOP_FILE
    else
      #value='$ITEM'
      echo -n ' ' >>$BASH_LOOP_FILE
      echo -n 'echo "$ITEM" | ' >>$BASH_LOOP_FILE
      #echo -n "./$COMMAND_FOLDER/$key.sh $value" >>$BASH_LOOP_FILE
      #echo -n " | " >>$BASH_LOOP_FILE
    fi
    first=

  done
  truncate -s -3 $BASH_LOOP_FILE

  echo "" >>$BASH_LOOP_FILE
  #echo "done" >>$BASH_LOOP_FILE
  echo 'done <<< "$list"' >>$BASH_LOOP_FILE
else
  truncate -s -3 $BASH_FILE
fi
## LOOP ##########################

#cat $CACHE_FILE
#cat $BASH_FILE
#cat $BASH_LOOP_FILE

#echo "RUN: $BASH_FILE" >> $LOGS
./$BASH_FILE
echo "END: $BASH_FILE" >>$LOGS

if [ "$OPTION" == "-l" ] || [ "$OPTION" == "--logs" ]; then
  echo -e "\n\nCOMMANDS:"
  cat $CACHE_FILE
  echo -e "\n\nSCRIPTS:"
  cat $BASH_FILE
  echo -e "\n\nLOGS:"
  cat $LOGS
fi
