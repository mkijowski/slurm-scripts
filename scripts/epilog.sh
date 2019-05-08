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
# Check for GPU processes
#
NVPATH=$(which nvidia-smi)
if [ -x "$NVPATH" ]; then
do
  # Clean up processes still running.  If processes don't exit node is drained.
  nvidia-smi pmon -c 1 | tail -n+3 | awk '{print $2}' | grep -v - > /dev/null
  if [ $? -eq 0 ] ; then
	  for i in `nvidia-smi pmon -c 1 | tail -n+3 | awk '{print $2}'`
		do
		  kill -9 $i
	  done
  fi
  sleep 5
  nvidia-smi pmon -c 1 | tail -n+3 | awk '{print $2}' | grep -v - > /dev/null
  if [ $? -eq 0 ] ; then
	  echo "Processes found"
	  scontrol update nodename=$HOSTNAME state=drain reason="Residual GPU processes found"
  else
	  echo "No processes found"
  fi
done
fi

#
# No other SLURM jobs, purge all remaining processes of this user
#
pkill -KILL -U $SLURM_UID
exit 0


