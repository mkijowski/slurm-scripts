#!/bin/bash

#enable logging
exec &> >( logger -t slurm-startup )

while true
do
  if mountpoint -q /home; then
    echo "/home mounted"
    sleep 1
    echo "Initializing nvidia devices"
    /etc/slurm/scripts/deviceQuery > /dev/null
    echo "nvidia init result: $?"
    sleep 5
    systemctl start slurmd
    break
  fi
  echo "No /home yet"
  sleep 10
done

