rm -f megae1_5.hgh
i=0; while test $i -lt 32768; do
	dd if=megae1_5.img bs=1 count=1 skip=$(($i * 2)) status=none >> megae1_5.hgh
	i=$(($i + 1))
done

rm -f megae1_5.low
i=0; while test $i -lt 32768; do
	dd if=megae1_5.img bs=1 count=1 skip=$(($i * 2 + 1)) status=none >> megae1_5.low
	i=$(($i + 1))
done

