#!/bin/sh
# Second unit
interval=600
# filter user
FUser="apache"
# wakealarm
wakealarm="/sys/class/rtc/rtc0/wakealarm"
# wake alarm status
RTime="/proc/driver/rtc"
# not set grep color
GREP_OPTIONS=""
# MySQL User
MySQL_USER=""
# MySQL User Password
MySQL_PASS=""
# MySQL DB Name
MySQL_DB=""
# Most recent job time
if ! [[ ${2:-0} =~ ^[0-9]+$ ]]; then echo $"Usage number: $2 is not digit" >&2; exit 4; fi
MRJTime="`date -d \"$(atq | sort -k2 -k3 | awk '$4 ~ /a/ && $5 ~ /'${FUser}'/ {print $2,$3}' | \
		head -${2:-1} | tail -1)\" +%s`"

show_atq() {
	atq | sort -k2 -k3
}

get_end_date() {
mysql -u ${MySQL_USER}  -p${MySQL_PASS} ${MySQL_DB} << EOFMYSQL
SELECT endtime,title FROM Recorder_reserveTbl where complete=0 order by endtime;
EOFMYSQL
}

show_reservations() {
mysql -u ${MySQL_USER}  -p${MySQL_PASS} ${MySQL_DB} << EOFMYSQL
SELECT starttime,endtime,title FROM Recorder_reserveTbl where complete=0 order by endtime;
EOFMYSQL
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
	echo $"or Usage: $0 {set|unset|status|restart|(date format:date --help)}" \
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
