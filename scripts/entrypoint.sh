#!/bin/bash
set -e

function shut_down() {
    echo "shutting down"
    apachectl -k stop
    exit
}

if test -f "/usr/local/etc/php/conf.d/uploads.ini"; then
  upload_ini=`cat /usr/local/etc/php/conf.d/uploads.ini`
fi

upload_ini="$upload_ini \n ${PHP_OTHER_CONFIG}"

if [[ $upload_ini == *"max_execution_time"* ]]
then
  echo "upload.ini conatains max_execution_time. Nothing done."
else
  echo "Added Set PHP max_execution_time to ${PHP_MAX_EXECUTION_TIME}"
  upload_ini="$upload_ini \n max_execution_time = ${PHP_MAX_EXECUTION_TIME}"
fi

if [[ $upload_ini == *"post_max_size"* ]]
then
  echo "upload.ini conatains post_max_size. Nothing done."
else
echo "Added Set PHP post_max_size to ${PHP_POST_MAX_SIZE}"
  upload_ini="$upload_ini \n post_max_size = ${PHP_POST_MAX_SIZE}"
fi

if [[ $upload_ini == *"upload_max_filesize"* ]]
then
  echo "upload.ini conatains upload_max_filesize. Nothing done."
else
echo "Added Set PHP upload_max_filesize to ${PHP_UPLOAD_MAX_FILESIZE}"
  upload_ini="$upload_ini \n upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}"
fi

printf "$upload_ini" > /usr/local/etc/php/conf.d/uploads.ini

apache2-foreground &

trap "shut_down" SIGKILL SIGTERM SIGHUP SIGINT EXIT

while true
do
  i="do nothing"
done

