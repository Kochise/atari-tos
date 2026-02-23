rm -f tt1_4.img
i=0; while test $i -lt 32768; do
	dd if=tt1_4.hgh bs=1 count=1 skip=$i status=none >> tt1_4.img
	dd if=tt1_4.low bs=1 count=1 skip=$i status=none >> tt1_4.img
	i=$(($i + 1))
done
