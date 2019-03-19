#!/bin/sh

set -x #trace on
set -e #break on error

# Remove fstab since we do not need them.
rm -f /etc/fstab

# Remove apk
rm -rf /var/cache/apk/*
rm -f /sbin/apk
rm -rf /etc/apk
rm -rf /lib/apk
rm -rf /usr/share/apk
rm -rf /var/lib/apk

# Remove all but a handful of admin commands.
#find /sbin /usr/sbin ! -type d \
#  -a ! -name nologin \
#  -delete

# Remove all but a handful of executable commands.
#find /bin /usr/bin ! -type d \
#  -a ! -name pwd \
#  -a ! -name cd \
#  -a ! -name ls \
#  -a ! -name sh \
#  -a ! -name bash \
#  -a ! -name dir \
#  -a ! -name mkdir \
#  -a ! -name find \
#  -a ! -name test \
#  -a ! -name touch \
#  -a ! -name chmod \
#  -a ! -name chown \
#  -delete

find /bin /usr/bin ! -type d \
  -name env \
  -delete
