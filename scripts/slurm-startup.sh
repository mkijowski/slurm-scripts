#!/bin/bash

#enable logging
exec &> >( logger -t slurm-startup )

for i in 1 2 3 4 5
do
  if mountpoint -q /home; then
    echo "/home mounted"
    sleep 1
    echo "Initializing nvidia devices"
    /etc/slurm/scripts/deviceQuery > /dev/null
    echo "nvidia init result: $?"
    sleep 1
    echo "Restarting slurmd service"
    systemctl start slurmd
    echo "slurmd service restart result: $?"
    echo "slurmd startup successful"
    break
  fi
  echo "No /home yet, sleeping 10s"
  sleep 10
done

if mountpoint -q /home; then
	echo "Move along"
else
	echo "error, /home failed to mount in 60s"
	echo "Did you forget to say the magic word?"
fi

