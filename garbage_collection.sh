#! /bin/bash

#settings
max_rec=$(( 1024*1024 )) #k
rec_dir="/.recycle/"

function usage() {
	echo -e "Linux recycle tool."
	echo -e "Usage: rc [target1 target2 ...] [option]\n"
	echo -e "Options:"
	echo -e "  -s  Show recycle pool stat"
	echo -e "  -c  Clear recycle pool"
	echo -e "  -l  List recycle pool content"
	echo
}

function not_found() {
	echo "rc: Can not stat '$1': No such file or directory."
	exit 1
}

function is_full() {
	if [ $(du -s /.recycle | awk '{print $1}') -gt $max_rec ]; then
		echo "Recycle pool full"
		echo "Clear recycle pool please."
		exit 1
	fi
}

function recycle_stat() {
	du_n=$(du -s /.recycle | awk '{print $1}')
	remain=$(( ($max_rec - $du_n) / 1024 )) #M
	echo "Recycle pool size $(( $max_rec / 1024 ))M"
	echo "Recycle pool avail ${remain}M"
	exit 0
}

function clear_recycle() {
	rm -rf ${rec_dir}*
	if [ $? == 0 ]; then
		echo "Clear recycle pool done."
		exit 0
	else
		echo "Clear recycle pool except."
		exit 1
	fi
}

function option_undefine() {
	echo "rc: option '$1' undefine."
	exit 1
}

function recycle() {
	mv -f $1 $rec_dir$(echo $1 | awk 'BEGIN{FS="/"} {print $NF}').$$
	exit $?
}

function list_recycle() {
	ls -alh $rec_dir
	exit $?
}

function main() {
	is_full

	for item in "$@"; do
		if [ ${item:0:1} == "-" ]; then
			case "$item" in
				"-s" )
					recycle_stat
					;;
				"-c" )
					clear_recycle
					;;
				"-l" )
					list_recycle
					;;
				  *	)
					option_undefine $item
					;;
			esac

			shift
			continue
		else
			if [ ! -f $item -a ! -d $item ]; then
				not_found $item
			fi

			recycle $item
		fi
	done

	if [ $# == 0 ]; then
		usage
		exit 1
	fi
}

main $@
