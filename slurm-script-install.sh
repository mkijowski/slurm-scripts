#!/bin/bash

# Must be root / sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root, exiting."
   exit 1
fi

# must have mkijowski
if [ ! -d /home/mkijowski ]; then
   read -p "Home directory for user mkijowski not found, enter username:" WHOAMI
else
   WHOAMI=mkijowski
fi

USERDIR=/home/$WHOAMI
SLURMSCRIPTDIR=/etc/slurm/scripts
GITDIR=$USERDIR/git/slurm-scripts

if [ ! -d $GITDIR ]; then
   echo "Cannot find git repo @ $GITDIR , exiting."
   exit 1
fi

mkdir -p $SLURMSCRIPTDIR

ln -sfb $GITDIR/scripts/epilog.sh $SLURMSCRIPTDIR/epilog.sh
ln -sfb $GITDIR/scripts/deviceQuery $SLURMSCRIPTDIR/deviceQuery
ln -sfb $GITDIR/scripts/taskprolog.sh $SLURMSCRIPTDIR/taskprolog.sh 
ln -sfb $GITDIR/scripts/slurm-startup.sh $SLURMSCRIPTDIR/slurm-startup.sh 

echo "
@reboot		root	$SLURMSCRIPTDIR/slurm-startup.sh" >> /etc/crontab

