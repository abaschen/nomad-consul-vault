#!/bin/sh
echo "+memory +pids +cpu +io" >>/sys/fs/cgroup/cgroup.subtree_control
echo "+memory +pids +cpu +io" >>/sys/fs/cgroup/user.slice/cgroup.subtree_control