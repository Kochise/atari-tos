rm -f st4_4.hgh
i=0; while test $i -lt 32768; do
	dd if=st4_4.img bs=1 count=1 skip=$(($i * 2)) status=none >> st4_4.hgh
	i=$(($i + 1))
done

rm -f st4_4.low
i=0; while test $i -lt 32768; do
	dd if=st4_4.img bs=1 count=1 skip=$(($i * 2 + 1)) status=none >> st4_4.low
	i=$(($i + 1))
done

