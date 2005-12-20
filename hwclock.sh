#!/bin/sh
# hwclock.sh	Set and adjust the CMOS clock, according to the UTC
#		setting in /etc/default/rcS (see also rcS(5)).
#
# Version:	@(#)hwclock.sh  2.00  14-Dec-1998  miquels@cistron.nl
#
# Patches:
#		2000-01-30 Henrique M. Holschuh <hmh@rcm.org.br>
#		 - Minor cosmetic changes in an attempt to help new
#		   users notice something IS changing their clocks
#		   during startup/shutdown.
#		 - Added comments to alert users of hwclock issues
#		   and discourage tampering without proper doc reading.

# WARNING:	Please read /usr/share/doc/util-linux/README.Debian.hwclock
#		before changing this file. You risk serious clock
#		misbehaviour otherwise.

. /etc/default/rcS
. /lib/lsb/init-functions
[ "$GMT" = "-u" ] && UTC="yes"
case "$UTC" in
       no|"") GMT="--localtime"	;;
       yes)   GMT="--utc" 	;;
       *)     log_failure_msg "Unknown UTC setting: \"$UTC\"" >&2 ;;
esac

case "$BADYEAR" in
       no|"") BADYEAR=""	;;
       yes)   BADYEAR="--badyear" 	;;
       *)     log_failure_msg "Unknown BADYEAR setting: \"$BADYEAR\"" >&2 ;;
esac

case "$1" in
	start)
		if [ ! -f /etc/adjtime ]
		then
			echo "0.0 0 0.0" > /etc/adjtime
		fi

		# Uncomment the hwclock --adjust line below if you want
		# hwclock to try to correct systematic drift errors in the
		# Hardware Clock.
		#
		# WARNING: If you uncomment this option, you must either make
		# sure *nothing* changes the Hardware Clock other than
		# hwclock --systohc, or you must delete /etc/adjtime
		# every time someone else modifies the Hardware Clock.
		#
		# Common "vilains" are: ntp, MS Windows, the BIOS Setup
		# program.
		#
		# WARNING: You must remember to invalidate (delete)
		# /etc/adjtime if you ever need to set the system clock
		# to a very different value and hwclock --adjust is being
		# used.
		#
		# Please read /usr/share/doc/util-linux/README.Debian.hwclock
		# before enablig hwclock --adjust.
		#
		# hwclock --adjust $GMT $BADYEAR

		if [ "$HWCLOCKACCESS" != no ]
		then
		    log_begin_msg "Setting the System Clock using the Hardware Clock as reference..."
		# Copies Hardware Clock time to System Clock using the correct
		# timezone for hardware clocks in local time, and sets kernel
		# timezone. DO NOT REMOVE.
			/sbin/hwclock --hctosys $GMT $BADYEAR
		#
		#	Now that /usr/share/zoneinfo should be available,
		#	announce the local time.
		#
		    if [ "$VERBOSE" != no ]
		    then
			log_success_msg "System Clock set. Local time: `date`"
		    fi
		    log_end_msg 0
		else
		    if [ "$VERBOSE" != no ]
		    then
			log_warning_msg "Not setting System Clock..."
		    fi
		fi
		;;
	stop|restart|reload|force-reload)
		#
		# Updates the Hardware Clock with the System Clock time.
		# This will *override* any changes made to the Hardware Clock.
		#
		# WARNING: If you disable this, any changes to the system
		#          clock will not be carried across reboots.
		#
		if [ "$HWCLOCKACCESS" != no ]
		then
		    log_begin_msg "Saving the System Clock time to the Hardware Clock..."
		    [ "$GMT" = "-u" ] && GMT="--utc"
			/sbin/hwclock --systohc $GMT $BADYEAR
		    if [ "$VERBOSE" != no ]
		    then
			log_success_msg "Hardware Clock updated to `date`."
		    fi
		else
		    if [ "$VERBOSE" != no ]
		    then
			log_warning_msg "Not saving System Clock..."
		    fi
		fi
		;;
	show)
		if [ "$HWCLOCKACCESS" != no ]
		then
			/sbin/hwclock --show $GMT $BADYEAR
		fi
		;;
	*)
		log_success_msg "Usage: hwclock.sh {start|stop|reload|force-reload|show}" >&2
		log_success_msg "       start sets kernel (system) clock from hardware (RTC) clock" >&2
		log_success_msg "       stop and reload set hardware (RTC) clock from kernel (system) clock" >&2
		exit 1
		;;
esac

