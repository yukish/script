#!/bin/sh
# Stop priority is higher than atq.
# chkconfig: 345 99 1
# Second unit
interval=600
# filter user
FUser="apache"
# MySQL Database
MYSQL_DB_NAME=""
# MySQL user name
MYSQL_USER=""
# MySQL password
MYSQL_PASS=""
# wakealarm
wakealarm="/sys/class/rtc/rtc0/wakealarm"
# wake alarm status
RTime="/proc/driver/rtc"
# not set grep color
GREP_OPTIONS=""
# Most recent job time
if ! [[ ${2:-0} =~ ^[0-9]+$ ]]; then echo $"Usage number: $2 is not digit" >&2; exit 4; fi
MRJTime="`date -d \"$(atq | sort -k2 -k3 | awk '$4 ~ /a/ && $5 ~ /'${FUser}'/ {print $2,$3}' | \
		head -${2:-1} | tail -1)\" +%s`"

show_atq() {
	atq | sort -k2 -k3
}

get_end_date() {
mysql -u ${MYSQL_USER} -p${MYSQL_PASS} ${MYSQL_DB_NAME} << EOFMYSQL
SELECT endtime,title FROM Recorder_reserveTbl where complete=0 order by endtime;
EOFMYSQL
	return_code=$?
	if [ $return_code -ne 0 ]; then
		exit $return_code
	fi
}

show_reservations() {
mysql -u ${MYSQL_USER} -p${MYSQL_PASS} ${MYSQL_DB_NAME} << EOFMYSQL
SELECT starttime,endtime,title FROM Recorder_reserveTbl where complete=0 order by endtime;
EOFMYSQL
	return_code=$?
	if [ $return_code -ne 0 ]; then
		exit $return_code
	fi
}

unsetwake() {
	echo 0 > ${wakealarm} &&
	echo "Wake alarm reseted."
	cat ${RTime}
}

setwake() {
	[ -f ${wakealarm} -a -f ${RTime} ] || exit 5
	echo $((${MRJTime} - ${interval})) > ${wakealarm} &&
	echo "Wake alarm status"
	cat ${RTime}
}

restart() {
	stop
	start
}

error() {
	echo $"or Usage: $0 {set|unset|status|restart|end|res|(date format:date --help)}" >&2 \
		|| exit 2
}
case "$1" in
	start)
		;;
	reset|unset)
		unsetwake
		;;
	stop|set)
		setwake
		;;
	status)
		cat ${RTime}
		;;
	restart)
		$1
		;;
	atq)
		show_atq
		;;
	end)
		get_end_date | /bin/grep '20[0-9]\{2\}'
		;;
	res|reservations)
		(printf "Date\tStart\tEnd\tTitle\n" \ ;
		show_reservations | /bin/grep '20[0-9]\{2\}' | awk '{print $1,$2,$4,$5}') \
		| column -t
		;;
	*)
		echo $((`date -d "$1" +%s` - 600)) > ${wakealarm}
		;;
esac
exit $?
