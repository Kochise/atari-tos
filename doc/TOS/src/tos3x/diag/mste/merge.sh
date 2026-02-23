rm -f megae1_5.img
i=0; while test $i -lt 32768; do
	dd if=megae1_5.hgh bs=1 count=1 skip=$i status=none >> megae1_5.img
	dd if=megae1_5.low bs=1 count=1 skip=$i status=none >> megae1_5.img
	i=$(($i + 1))
done
