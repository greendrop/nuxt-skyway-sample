#!/bin/bash

if [ -z "$USER_ID" ]; then
  echo "USER_ID variable is not defined."
  exit 1;
fi

if [ -z "$GROUP_ID" ]; then
  echo "GROUP_ID variable is not defined."
  exit 1;
fi

getent passwd $USER_ID > /dev/null
user_result=$?
getent group $GROUP_ID > /dev/null
group_result=$?

set -e

# User settings
USER=$USER_ID
unset USER_ID
GROUP=$GROUP_ID
unset GROUP_ID
if [ $user_result -ne 0 ]; then
  echo "docker:x:$USER:$GROUP:docker:/home/docker:/bin/bash" >> /etc/passwd
fi
if [ $group_result -ne 0 ]; then
  echo "docker:x:$GROUP:" >> /etc/group
fi
echo "docker ALL=NOPASSWD: ALL" > /etc/sudoers.d/docker

# Directories settings
chown $USER:$GROUP /home/docker

# Environments settings
if [ -n "$ADDITIONAL_PATH" ]; then
  export PATH=$ADDITIONAL_PATH:$PATH
  unset ADDITIONAL_PATH
fi

exec gosu $USER:$GROUP "$@"
