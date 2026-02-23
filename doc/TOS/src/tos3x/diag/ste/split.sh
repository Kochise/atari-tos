rm -f ste1_9.hgh
i=0; while test $i -lt 32768; do
	dd if=ste1_9.img bs=1 count=1 skip=$(($i * 2)) status=none >> ste1_9.hgh
	i=$(($i + 1))
done

rm -f ste1_9.low
i=0; while test $i -lt 32768; do
	dd if=ste1_9.img bs=1 count=1 skip=$(($i * 2 + 1)) status=none >> ste1_9.low
	i=$(($i + 1))
done

