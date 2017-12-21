#!/usr/bin/env bash

# be sure to change the paths!

# strip control characters from metadata.xml
find /path/to/files -type f -name 'metadata.xml' | while read line; do N=`echo $line | sed 's/\.xml/.new.xml/'`; cat $line | tr -d "\000-\007\010\013\014\016-\031" > $N; done

# sleep for a second
sleep 1

# move new files to their appropriate name
find /path/to/files -type f -name 'metadata.new.xml' | while read line; do N=`echo $line | sed 's/\.new.xml/.xml/'`; mv -f $line $N; done