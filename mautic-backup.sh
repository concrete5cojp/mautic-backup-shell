#!/bin/sh
#
# Mautic backup shell:
# ----------
# Version 0.1a
# By katzueno

# INSTRUCTION:
# ----------
# https://github.com/katzueno/mautic-backup-shell

# USE IT AT YOUR OWN RISK!

set -e

# VARIABLES
# ----------
NOW_TIME=$(date "+%Y%m%d%H%M%S")
WHERE_TO_SAVE="/var/www/html/backup"
WHERE_IS_MAUTIC="/var/www/html/www"
FILE_NAME="katzueno"
MYSQL_SERVER="localhost"
MYSQL_NAME="database"
MYSQL_USER="root"
# MYSQL_PASSWORD="pass"

# ==============================
#
# DO NOT TOUCH BELOW THIS LINE (unless you know what you're doing.)
#
# ==============================

# ---- Checking The Options -----
BASE_PATH=''
if [ "$2" = "-a" ] || [ "$2" = "--absolute" ]; then
    BASE_PATH="${WHERE_IS_MAUTIC}"
elif [ "$2" = "-r" ] || [ "$2" = "--relative" ] || [ "$2" = "" ]; then
    BASE_PATH="."
else
    NO_2nd_OPTION="1"
fi

if [ "$1" = "--all" ] || [ "$1" = "-a" ] || [ "$1" = "" ]; then
    echo "Mautic Backup: You've chosen the ALL option. Now we're backing up all concrete5 directory files."
    ZIP_OPTION="${BASE_PATH}/${FILE_NAME}_${NOW_TIME}.sql ${BASE_PATH}/"
    NO_OPTION="0"
elif [ "$1" = "--database" ] || [ "$1" = "-d" ]; then
    echo "Mautic Backup: You've chosen the DATABASE option. Now we're only backing up the SQL file."
    ZIP_OPTION="${BASE_PATH}/${FILE_NAME}_${NOW_TIME}.sql"
    NO_OPTION="0"
elif [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "
    ====================
    Mautic Backup: Options
    ====================
    --------------------
    First Option
    --------------------
    --all OR -a: back up a SQL and all files under WHERE_IS_MAUTIC path
    --database OR -d: back up only a SQL dump
    --help OR -h: This help option.
    --------------------
    Second Option
    --------------------
    -r OR --relative: This is default option. You can leave this option blank
    -a OR --absolute: The script will execute using absolute path. Zip file may contain the folder structure
    
    * Second option is optional. You must specify 1st option if you want to specify 2nd option.
    ====================
    
    Have a good day! from katzueno.com
"
    exit
else
    NO_OPTION="1"
fi

if [ "$NO_OPTION" = "1" ] || [ "$NO_2nd_OPTION" = "1" ]; then
    echo "Mautic Backup ERROR: You specified WRONG OPTION. Please try 'sh backup.sh -h' for the available options."
    exit
fi

# ---- Checking Variable -----
echo "Mautic Backup: Checking variables..."
if [ -z "$WHERE_TO_SAVE" ] || [ "$WHERE_TO_SAVE" = " " ]; then
    echo "Mautic Backup ERROR: WHERE_TO_SAVE variable is not set"
    exit
fi
if [ -z "$WHERE_IS_MAUTIC" ] || [ "$WHERE_IS_MAUTIC" = " " ]; then
    echo "Mautic Backup ERROR: WHERE_IS_MAUTIC variable is not set"
    exit
fi
if [ -z "$NOW_TIME" ] || [ "$NOW_TIME" = " " ]; then
    echo "Mautic Backup ERROR: NOW_TIME variable is not set"
    exit
fi
if [ -z "$MYSQL_SERVER" ] || [ "$MYSQL_SERVER" = " " ]; then
    echo "Mautic Backup ERROR: MYSQL_SERVER variable is not set"
    exit
fi
if [ -z "$MYSQL_USER" ] || [ "$MYSQL_USER" = " " ]; then
    echo "Mautic Backup ERROR: MYSQL_USER variable is not set"
    exit
fi
if [ -z "$MYSQL_NAME" ] || [ "$MYSQL_NAME" = " " ]; then
    echo "Mautic Backup ERROR: MYSQL_NAME variable is not set"
    exit
fi

# ---- Starting shell -----
echo "===================="
echo "Mautic Backup: USE IT AT YOUR OWN RISK!"
echo "===================="
echo "Mautic Backup:"
echo "Mautic Backup: Starting concrete5 backup..."

# ---- Executing the commands -----
echo "Mautic Backup: Switching current directory to"
echo "${WHERE_IS_MAUTIC}"
cd ${WHERE_IS_MAUTIC}
echo "Mautic Backup: Executing MySQL Dump..."

if [ -n "$MYSQL_PASSWORD" ]; then
    set +e
        mysqldump -h ${MYSQL_SERVER} -u ${MYSQL_USER} --password=${MYSQL_PASSWORD} --single-transaction --default-character-set=utf8 ${MYSQL_NAME} > ${BASE_PATH}/${FILE_NAME}_${NOW_TIME}.sql
    ret=$?
    if [ "$ret" = 0 ]; then
        echo ""
        echo "Mautic Backup: MySQL Database was dumped successfully."
    else
        echo "Mautic Backup: ERROR: MySQL password failed. You must type MySQL password manually. OR hit ENTER if you want to stop this script now."
        set -e
        mysqldump -h ${MYSQL_SERVER} -u ${MYSQL_USER} -p --single-transaction --default-character-set=utf8 ${MYSQL_NAME} > ${BASE_PATH}/${FILE_NAME}_${NOW_TIME}.sql
    fi
    set -e
else
    echo "Mautic Backup: Enter the MySQL password..."
    mysqldump -h ${MYSQL_SERVER} -u ${MYSQL_USER} -p --single-transaction --default-character-set=utf8 ${MYSQL_NAME} > ${BASE_PATH}/${FILE_NAME}_${NOW_TIME}.sql
fi

echo "Mautic Backup: Now zipping files..."
zip -r -q ${BASE_PATH}/${FILE_NAME}_${NOW_TIME}.zip ${ZIP_OPTION}
# tar cfz ${BASE_PATH}/${FILE_NAME}_${NOW_TIME}.tar ${ZIP_OPTION}

echo "Mautic Backup: Now removing SQL dump file..."
rm -f ${BASE_PATH}/${FILE_NAME}_${NOW_TIME}.sql

echo "Mautic Backup: Now moving the backup file(s) to the final destination..."
echo "${WHERE_TO_SAVE}"
mv ${BASE_PATH}/${FILE_NAME}_${NOW_TIME}.zip ${WHERE_TO_SAVE}
# mv ${BASE_PATH}/${FILE_NAME}_${NOW_TIME}.tar ${WHERE_TO_SAVE}

echo "Mautic Backup: Completed!"
