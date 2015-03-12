#!/bin/bash
start=`date +%s`
#Location of Script
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#Destination Directory on Acquia Server for tar balls
BASE_DEST_DIR=/mnt/tmp/backups/

#URL for Cloud API
URL=https://www.govcms.acsitefactory.com/api/v1/sites?limit=200

#Username for Cloud API
USER="gov hosting"

#API Key for Cloud API
KEY=key_here

#Drush Aliases File
END_FILE=${SCRIPT_DIR}/govcms.aliases.drushrc.php

clear
CWD=`pwd`
#colors
red='\033[0;31m'
green='\033[0;32m'
orange='\033[0;33m'
NC='\033[0m'
#Starting file for drush aliases
START_PHP="<?php "
START_FILE="\$aliases['acquia-cloud'] = array('path-aliases' => array('%drush-script' => 'drush6','%dump-dir' => '/mnt/tmp/'));"
TEMPLATE="\$aliases['aliasname']=array('parent'=>'@acquia-cloud','uri'=>'aliasname','root'=>'/var/www/html/govcms.01live/docroot','remote-host'=>'web-256.enterprise-g1.hosting.acquia.com','remote-user'=>'govcms.01live','ssh-options'=>'-F /dev/null');
"
DATE=`date +%Y-%m-%d`
echo "ACSF Site Archiving starting $(date) and running as $USER from $SCRIPT_DIR"
echo -e "URL set to $URL\n"

OUTPUT="$(curl -u "$USER":$KEY $URL)"
COUNT=$(echo $OUTPUT | jq -r '.count')
echo -e "${red}Number of Sites [$COUNT]${NC}\n"
SITE_IDS=$(echo $OUTPUT | jq '.sites[].id')
SITE_URIS=$(echo $OUTPUT | jq -r '.sites[].domain')
SITE_ARRAY=$( echo $SITE_URIS | tr " " "\n")
echo $START_PHP > $END_FILE
echo $START_FILE >> $END_FILE
for domain in $SITE_ARRAY
do
    echo -e "Writing domain [$domain] into [$END_FILE]\n"
    echo "$TEMPLATE" | sed -r "s/aliasname/$domain/g" >> $END_FILE    
    echo "Written domain [$domain] into [$END_FILE]"
done
echo "Aliases File finished writing"
echo "" >> $END_FILE
#Copy File to .drush directory so we can start running drush commands
rm -f ~/.drush/$END_FILE
cp -f $END_FILE ~/.drush/
cd ~/.drush/
echo -e "\n\n"
for url in $SITE_ARRAY
do
    echo "Getting Dump of $url"
    drush @$url archive-dump --destination="${BASE_DEST_DIR}${url}.tar.gz" --overwrite
    echo "Dump complete"
    mkdir -p $SCRIPT_DIR/backups/$DATE/$url/
    chmod -R 777 $SCRIPT_DIR/backups/
    echo "Retrieving $url dump"
    drush -y rsync @$url:${BASE_DEST_DIR}${url}.tar.gz $SCRIPT_DIR/backups/$DATE/$url/
    echo "Retrieved $url dump"
done

end=`date +%s`
echo "ACSF Site Archiving finished $(date) took [$((end-start))] seconds"
cd $CWD
