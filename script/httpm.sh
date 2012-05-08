#!/bin/sh

#
# httpm, an HTTP server developed using GT.M
# Copyright (C) 2012 Laurent Parenteau <laurent.parenteau@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

if [ "$2" != "" ] ; then
	configfile="$2"
else
	configfile="conf/httpm.conf"
fi

if [ ! -f $configfile ] ; then
	echo "Configuration file does not exist."
	exit 1
fi

source $configfile
progname="httpm"

function checkpid() {
	if [ -f $pid ] ; then
		ps -p `cat $pid` > /dev/null
		status="$?"
	else
		status="1"
	fi
}

function start() {
	echo "Starting $progname."
	checkpid
	if [ "0" = "$status" ] ; then
		echo "$progname is already running."
	else
		rm -f $pid
		echo "Starting $progname at " `date` " using configfile." >> $log
		TZ="Europe/London" nohup $gtm_dist/mumps -run start^httpm < /dev/null >> $log 2>&1 &
		echo $! > $pid
	fi
}

function stop() {
	echo "Stoping $progname."
	checkpid
	if [ "0" = "$status" ] ; then
		$gtm_dist/mupip stop `cat $pid`
		echo "Stopped $progname at " `date` " using configfile." >> $log
	else
		echo "$progname is not running."
	fi
	rm -f $pid
}

function status() {
	echo "Checking for $progname."
	checkpid
	if [ "0" = "$status" ] ; then
		echo "$progname is running."
	else
		echo "$progname is not running."
	fi
}

case "$1" in
	start)
		start
		sleep 1
		status
		;;
	stop)
		stop
		;;
	restart)
		stop
		start
		;;
	status)
		status
		;;
	*)
		echo "Usage: $0 {start|stop|status|restart} <configfile>"
		exit 1
		;;
esac

exit 0
