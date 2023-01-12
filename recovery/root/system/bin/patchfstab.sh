#!/system/bin/sh
# This script is needed to support wrappedkey and fbe v2
# Author : brigudav
#

n=1

while [ $n -le 2 ]; do

finish() {
	sleep 1
	umount $tmpv || true
	rmdir $tmpv
	exit 1
}

logf=/tmp/recovery.log
tmpv=/tmp/vendor_fstab
mkdir -p $tmpv
fstabd=$tmpv/etc/fstab.default
fstabq=$tmpv/etc/fstab.qcom
fstabr=/system/etc/recovery.fstab
mount -o ro -t auto /dev/block/mapper/vendor $tmpv || true
if [ -f $fstabq ]; then
	fbev2=$(grep "/userdata" ${fstabq} | grep ":v2")
	echo "I:Find $fstabq" >> $logf
	if [ -z "$fbev2" ]; then
		echo "I:This ROM not support FBE v2. Changing flags in fstab" >> $logf
		cp $fstabr.bak $fstabr
		wrapv=$(grep "/userdata" ${fstabq} | grep "wrappedkey")
		if [ -n "$wrapv" ]; then
			echo "I:And enabled supports wrappedkey..." >> $logf
			sed -i -e "s/formattable/formattable,wrappedkey/g" $fstabr
		fi
		finish
	else
		echo "I:This ROM with FBE v2. Continuing with the default fstab." >> $logf
		finish
	fi
elif [ -f $fstabd ]; then
	cp $fstabr.bak $fstabr
	wrap=$(grep "/userdata" ${fstabd} | grep "wrappedkey")
	echo "I:Find $fstabd" >> $logf
	if [ -n "$wrap" ]; then
		echo "I:This ROM supports wrappedkey. Changing flags in fstab" >> $logf
		sed -i -e "s/formattable/formattable,wrappedkey/g" $fstabr
	fi
	finish
fi
sleep 1
done

exit 0
