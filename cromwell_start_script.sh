#!/bin/bash

DEFAULT_LOCAL_CKPT_FILE="./ckpt"

LOCAL_CKPT_FILE=$DEFAULT_LOCAL_CKPT_FILE
SCRIPTNAME=$( echo $0 | sed 's#.*/##g' )

display_help() {
  echo -e ""
  echo -e "-- $SCRIPTNAME --"
  echo -e ""
  echo -e " Copy the remote_ckpt to the specified local path. "
  echo -e ""
  echo -e " Example usage:"
  echo -e "   $SCRIPTNAME $LOCAL_CKPT_FILE"
  echo -e "   $SCRIPTNAME -h"
  echo -e ""
  echo -e " Supported Flags:"
  echo -e "   -h or --help     Display this message"
  echo -e ""
  echo -e " Default behavior (can be changed manually by editing the $SCRIPTNAME):"
  echo -e "   If no inputs are specified the default values will be used:"
  echo -e "   local_ckpt -----------> $LOCAL_CKPT_FILE"
  echo -e ""
}

exit_remote_ckpt_does_not_exist() {
  echo -e ""
  echo -e "SORRY!. Remote ckpt does not exist!"
  exit 1
}

exit_remote_ckpt_exists() {
  echo -e ""
  echo -e "GREAT!. Remote ckpt exists!"
  exit 0
}


# 1. read inputs from command line
POSITIONAL=""
while [[ $# -gt 0 ]]; do
	case "$1" in
		h|--help)
			display_help
			exit 0
			;;
		*) # positional
			LOCAL_CKPT_FILE=$1
			shift
			;;
	esac
done  # end of while loop

# 2. gather information
LOCAL_CKPT_DIR=$(dirname "$LOCAL_CKPT_FILE")
mkdir -p $LOCAL_CKPT_DIR
REMOTE_CKPT_DIR=$(cat gcs_delocalization.sh | grep -o 'gs:\/\/.*stdout"' | grep -o 'gs:\/\/.*\/call[^\/]*')
REMOTE_CKPT_FILE=$REMOTE_CKPT_DIR/ckpt

echo "Current values: -->" $LOCAL_CKPT_FILE $LOCAL_CKPT_DIR $REMOTE_CKPT_DIR $REMOTE_CKPT_FILE

# 3. Copy remote ckpt to local ckpt if it exists
export GCS_OAUTH_TOKEN='gcloud auth application-default print-access-token'
return_code=$(gsutil -q stat $REMOTE_CKPT_FILE; echo $?)  # 0=exist, 1=does not exists
if [ $return_code == '0' ]; then
    echo "remote_ckpt EXISTS"
    exit_remote_ckpt_exists()
else
    exit_remote_ckpt_does_not_exist()
fi
