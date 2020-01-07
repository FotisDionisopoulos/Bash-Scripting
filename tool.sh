#!/bin/sh
#5753
#FOTIOS DIONISOPOULOS



has_file=0
file_pos=0
has_id=0
id_pos=0
firstnames=0
lastnames=0
browsers=0
b_since=0
b_since_pos=0
b_until=0
b_until_pos=0
edit=0
edit_pos=0
edit_value=0
edit_id=0

#Gia kathe orisma ginete elegxos mesw twn if. Ean brei kapoio token tote enhmerwnei mia metablhth(h opoia leitourgei san flag)
#Epishs, apothhkeyetai kai h thesh pou exei to token sth eisodo gia mellontikh xrhsh
for ((i=1;i<=$#;i++))
do
	if [ ${!i} = -f ]; then 
		file_pos=${i}
		file_pos=$((file_pos+1))
		if [ -f ${!file_pos} ]; then 
			has_file=1
		fi
	fi
	
	if [ ${!i}  = -id ]; then 
		id_pos=${i}
		id_pos=$((id_pos+1))
		if [ -n ${!id_pos} ]; then 
			has_id=1
		fi	 
	fi
	
	if [  ${!i}  = --firstnames ]; then
		firstnames=1
	fi
	
	if [  ${!i}  = --lastnames ]; then
		lastnames=1
	fi
	
	if [  ${!i}  = --browsers ]; then
		browsers=1
	fi
	
	if [  ${!i}  = --born-since ]; then
		b_since_pos=${i}
		b_since_pos=$((b_since_pos+1))
		if [ -n ${!b_since_pos} ]; then 
			b_since=1
		fi
	fi
	
	if [  ${!i}  = --born-until ]; then
		b_until_pos=${i}
		b_until_pos=$((b_until_pos+1))
		if [ -n ${!b_until_pos} ]; then 
			b_until=1
		fi
	fi
	
	if [  ${!i} = --edit ]; then
		edit_pos=${i}
		edit_pos=$((edit_pos+1))
		edit_id=$((edit_pos))
		if [ -n ${!edit_id} ]; then
			edit_pos=${i}
			edit_pos=$((edit_pos+2))
			edit_col=$((edit_pos))
			if [[ $edit_col -gt 2  &&  $edit_col -le 8 ]]; then
				edit_pos=${i}
				edit_pos=$((edit_pos+3))
				edit_value=$((edit_pos))
				if [ -n ${!edit_value} ]; then
					edit=1
				fi
			fi
		fi
	fi
done


#1
if [ ! -n "$1" ]; then
	#Ean to 1o orisma einai keno, tote emfanizei mono to AM
	echo "5753"
fi

#2
if [[ $has_file -eq 1 && -z "$3" ]]; then
	#Ean exei arxeio kai den yparxei 3o orisma, tote ektypwnei to arxeio
	awk '!/#/ {print}' "${!file_pos}"
fi

#3
if [[ has_file -eq 1 && has_id -eq 1 ]]; then
	#Elegxei ean to id uparxei sto $1(id column), ean yparxei tote ektypwnei tis aparaithtes thmes
	awk -v arg=${!id_pos} -F"|" '!/#/ {if(arg == $1)print $2,$3,$5}' "${!file_pos}"
fi

#4
if [[ $firstnames -eq 1 && $has_file -eq 1 ]]; then
	#Dimiourgei enan pinaka toy opoioy to index  den einai onomata.Elegxei kathe fora 
	#ean to onoma yparxei, ean den yparxei tote to bazei se enan neo pinaka
	#Telos,  ta taksinomei me thn sort
	awk -F"|" '!/#/ && !firstnm[$2]++ {print $2}' "${!file_pos}"|sort
fi

#5
if [[ $lastnames -eq 1 && $has_file -eq 1 ]]; then
	#Dimiourgei enan pinaka toy opoioy to index  den einai epwnyma.Elegxei kathe fora 
	#ean to epwmymo yparxei, ean den yparxei tote to bazei se enan neo pinaka
	#Telos,  ta taksinomei me thn sort
	awk -F"|" '!/#/ && !lastnm[$3]++ {print $3}' "${!file_pos}"|sort
fi

#6
if [[ $b_until -eq 1  &&  $b_since -eq 1 ]]; then 
	#H if mesa sthn awk elegxei ean o hmeromhnia einai mesa sta oria, ean einai ektypwnei th grammh
	awk -F"|" -v since="${!b_since_pos}" -v until="${!b_until_pos}" '!/#/{if(($5>=since)&&($5<=until))print}' "${!file_pos}"
fi

if [[ $b_until -eq 1  &&  $b_since -eq 0 ]]; then 
	#H if mesa sthn awk elegxei ean o hmeromhnia einai prin thn until, ean einai ektypwnei th grammh
	awk -F"|" -v until="${!b_until_pos}" '!/#/ {if($5<=until)print}' "${!file_pos}"
fi

if [[ $b_until -eq 0  &&  $b_since -eq 1 ]]; then 
	#H if mesa sthn awk elegxei ean o hmeromhnia einai meta thn since, ean einai ektypwnei th grammh
	awk -F"|" -v since="${!b_since_pos}" '!/#/&& $5>=since {if($5>=since)print}' "${!file_pos}"
fi

#7
if [[ $browsers -eq 1 && $has_file -eq 1 ]]; then
	#Dimiourgei enan pinaka toy opoioy to index  den einai aritmoi, alla einai ta onomata twn browsers.Mesa sto kathe keli
	#yparxei to aritmos pou dhlwnei poses fores emfanizetai o sygkekrimenos browser.Ektypwnei ta periexomena mesw 
	#ths for kai ta taksinomei mesw ths sort
	awk -F"|" '!/#/{++br_cnt[$8]}END{for(i in br_cnt) print i,br_cnt[i]}' "${!file_pos}" |sort
fi

#8
if [ $edit -eq 1 ]; then
	#Ean yparxei to ID pou tha dwsei o xrhsths, tote allazei h timh tou column pou exei epileksei o xrhsths.Ola ta periexomena ektypwnontai
	#mesa se ena proswrino arxeio to opoio onomazetai filea, to opoio sth synexeia metonomazetai sto onoma toy arxeioy pou edwse o xrhsths 
	#otan kalese to scripr
	awk -F "|" -v am=${!edit_id} -v column=${!edit_col} -v value=${!edit_value} 'BEGIN{OFS="|"} !/#/{if (am == $1){$column=value}}1' "${!file_pos}" > filea && mv filea "${!file_pos}"
fi
