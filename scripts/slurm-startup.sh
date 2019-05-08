#!/bin/bash

#enable logging
exec &> >( logger -t slurm-startup )

while true
do
  if mountpoint -q /home; then
    /etc/slurm/scripts/deviceQuery > /dev/null
    systemctl start slurmd
    break
  fi
  sleep 10
done

