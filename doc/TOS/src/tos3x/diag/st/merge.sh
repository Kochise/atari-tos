rm -f st4_4.img
i=0; while test $i -lt 32768; do
	dd if=st4_4.hgh bs=1 count=1 skip=$i status=none >> st4_4.img
	dd if=st4_4.low bs=1 count=1 skip=$i status=none >> st4_4.img
	i=$(($i + 1))
done
