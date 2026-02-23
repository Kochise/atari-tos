rm -f TT_Test_v1.4.hgh
i=0; while test $i -lt 32768; do
	dd if=TT_Test_v1.4.img bs=1 count=1 skip=$(($i * 2)) status=none >> TT_Test_v1.4.hgh
	i=$(($i + 1))
done

rm -f TT_Test_v1.4.low
i=0; while test $i -lt 32768; do
	dd if=TT_Test_v1.4.img bs=1 count=1 skip=$(($i * 2 + 1)) status=none >> TT_Test_v1.4.low
	i=$(($i + 1))
done

