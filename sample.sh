#!/bin/bash
## A sample shell script to demo concept of shell parameter expansion
## Usage: backup.bash /path/to/backup.tar.gz 
## Author: nixCraft <www.cyberciti.biz> under GPL v2.x+
## -------------------------------------------------------------------
 
## Get our script name ##
_me="${0##*/}"
 
## get filename from cmd arg $1
_backuppath="$1"
 
## Failsafe 
[[ $# -ne 1 ]] && { echo -en "Usage:\t$_me /path/to/file.tar\n\t$_me /path/to/file.tgz\n"; exit 1; }
 
## Backup these dirs 
_what="/etc /home /root"
 
## Get dirname 
_dirname="${_backuppath%/*}"
 
# Get filename 
_filename="${_backuppath##*/}"
 
# Get file extension 
_extesion="${_filename##*.}"
 
# Set tar options
_opt=""
 
# Old backup file name starts with
_oldsuff="old"
 


echo $_what
echo $_me
echo $_backuppath
echo $_dirname
echo $_filename
echo $_extension
 
## Okay log data to syslog
logger "$_me backup job started at $(date)@${HOSTNAME}"
 
## make decision based upon file extension
[[ "$_extesion" == "tgz" ]] && { _opt="zcvf"; _oldpref="tgz"; }
[[ "$_extesion" == "tar" ]] && { _opt="cvf"; _oldpref="tar";  }
 
 
## Just display commands for demo purpose ##
echo "tar $_opt /tmp/${_filename} $_what"
echo "mv -f ${_backuppath} ${_dirname}/${_oldsuff}.${_filename%.*}.${_oldpref}"
echo "cp -f /tmp/${_filename} ${_backuppath}"
 
logger "$_me backup job ended at $(date)@${HOSTNAME}"
