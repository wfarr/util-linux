#!/bin/bash
# hwclockfirst.sh Set system clock to hardware clock, according to the UTC
#               setting in /etc/default/rcS (see also rcS(5)).
#
#
# WARNING:      Runs without write permission on /etc, and before
#               mounting all filesystems! If you need write permission
#               to do something, do it in hwclock.sh.
#
# WARNING:      If your hardware clock is not in UTC/GMT, this script
#               must know the local time zone. This information is
#               stored in /etc/localtime. This might be a problem if
#               your /etc/localtime is a symlink to something in
#               /usr/share/zoneinfo AND /usr isn't in the root
#               partition! The workaround is to define TZ either
#               in /etc/default/rcS, or in the proper place below.
#
# REMEMBER TO EDIT hwclock.sh AS WELL! 

# Set this to any options you might need to give to hwclock, such
# as machine hardware clock type for Alphas.
HWCLOCKPARS=

[ ! -x /sbin/hwclock ] && exit 0

. /etc/default/rcS
. /lib/lsb/init-functions

# Define TZ to the desired timezone here if you need it.
# see tzset(3) for how to define TZ.
# WARNING: TZ takes precedence over /etc/localtime !
TZ=


case "$UTC" in
       no|"") GMT="--localtime"
              UTC=""
              if [ ! -r /etc/localtime ]
		then
		if [ -z "$TZ" ]
		  then
		      log_warning_msg "System clock was not updated at this time."
                      exit 1
		 fi
              fi
              ;;
       yes)   GMT="--utc"
              UTC="--utc"
              ;;
       *)     log_failure_msg "Unknown UTC setting: \"$UTC\""
              exit 1
              ;;
esac


case "$1" in
        start)
                log_begin_msg "Setting the System Clock using the Hardware Clock as reference..."

		# Copies Hardware Clock time to System Clock using the correct
		# timezone for hardware clocks in local time, and sets kernel 
		# timezone. DO NOT REMOVE.
		if [ "$HWCLOCKACCESS" != no ]
		then
			/sbin/hwclock --hctosys $GMT $BADYEAR
		fi
                if [ "$VERBOSE" != no ]
                then
                        log_success_msg "System time was `date --utc`."
                fi

                # Copies Hardware Clock time to System Clock using the correct
                # timezone for hardware clocks in local time, and sets kernel
                # timezone. DO NOT REMOVE.
		if [ -z "$TZ" ]
		then
                   /sbin/hwclock --noadjfile --hctosys $GMT $HWCLOCKPARS
		else
		   TZ="$TZ" /sbin/hwclock --noadjfile --hctosys $GMT $HWCLOCKPARS
		fi

		if /sbin/hwclock --show $GMT $HWCLOCKPARS 2>&1 > /dev/null | grep -q '^The Hardware Clock registers contain values that are either invalid'; then
			echo "Invalid system date -- setting to 1/1/2002"
			/sbin/hwclock --set --date '1/1/2002 00:00:00' $GMT $HWCLOCKPARS
		fi
                
		log_end_msg $?
                if [ "$VERBOSE" != no ]
                then
                        log_success_msg "System Clock set. System local time is now `date $UTC`."
                fi
                ;;
        stop|restart|reload|force-reload)
                # Does nothing
                exit 0
                ;;
        *)
                log_success_msg "Usage: hwclockfirst.sh {start|stop|reload|restart}"
                log_success_msg "       start sets kernel (system) clock from hardware (RTC) clock"
                log_success_msg "       stop, restart, reload and force-reload do nothing."
                log_success_msg "       Refer to hwclock.sh as well."
                exit 1
                ;;
esac

