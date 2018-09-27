#!/bin/bash

# For details see https://www.packer.io/docs/builders/googlecompute.html#precedence-of-authentication-methods
DEFAULT_CREDENTIALS_PATH=$HOME/.config/gcloud/application_default_credentials.json
GOOGLE_APPLICATION_CREDENTIALS=${GOOGLE_APPLICATION_CREDENTIALS:-$DEFAULT_CREDENTIALS_PATH}

mkdir -p $(dirname $GOOGLE_APPLICATION_CREDENTIALS)
echo ${GOOGLE_CLOUD_KEYFILE_JSON:?} > $GOOGLE_APPLICATION_CREDENTIALS
