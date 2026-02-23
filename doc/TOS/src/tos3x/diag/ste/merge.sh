rm -f ste1_9.img
i=0; while test $i -lt 32768; do
	dd if=ste1_9.hgh bs=1 count=1 skip=$i status=none >> ste1_9.img
	dd if=ste1_9.low bs=1 count=1 skip=$i status=none >> ste1_9.img
	i=$(($i + 1))
done
