#!/bin/bash
#
# This script will kill any user processes on a node when the last
# SLURM job there ends. For example, if a user directly logs into
# an allocated node SLURM will not kill that process without this
# script being executed as an epilog.
#
# SLURM_BIN can be used for testing with private version of SLURM
#SLURM_BIN="/usr/bin/"
#
if [ x$SLURM_UID = "x" ] ; then 
	exit 0
fi
if [ x$SLURM_JOB_ID = "x" ] ; then 
        exit 0
fi

#
# Don't try to kill user root or system daemon jobs
#
if [ $SLURM_UID -lt 100 ] ; then
	exit 0
fi

job_list=`${SLURM_BIN}squeue --noheader --format=%A --user=$SLURM_UID --node=localhost`
for job_id in $job_list
do
	if [ $job_id -ne $SLURM_JOB_ID ] ; then
		exit 0
	fi
done

#
# No other SLURM jobs, purge all remaining processes of this user
#
pkill -KILL -U $SLURM_UID
exit 0


