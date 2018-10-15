#!/bin/bash -eux


SRC=/tmp/deployment
DST=/opt/wso2/wso2ei-6.2.0/repository/deployment/server/carbonapps
mkdir -p $DST
ls -lta $SRC
manifest=($(cat $SRC/manifest.list))


function in_array()
{
	for i in ${manifest[@]}
	do
		if [[ $i == $1 ]]
		then
			return 0
		fi
	done
}

# make sure wso2 user exists so not to fail
id -u wso2 &> /dev/null || useradd wso2

for f in ${manifest[@]}
do
	cp $SRC/$f  $DST/
	chown wso2 $DST/$f
done

for f in $(ls $DST)
do
	in_array $f || rm $DST/$f
done
