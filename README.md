# site-backup
Repository holding script which will run at SlicedTech to keep offsite backups

## Requirements
- jq (http://stedolan.github.io/jq/download/)
- bash shell

This script takes 2 arguments, the first is the username from acquia cloud API you want to use, the second is the API Key for that account.

e.g.
./site-backup.sh "user name" FSDJKSDNEWH432hkjfd@!#jkdnjkfhwkfe

Note: Recommend running this script as ./site-backup.sh "user name" api_key >> /log/file/here.log
