#!/usr/bin/env sh

curr_dir=`pwd`

for file in `find . -name "Plots.tgz" -print 2>/dev/null`
do
	echo $file
	tar_dir=`dirname $file`
	echo $tar_dir 
	tar -C $tar_dir -xvf $file
done
