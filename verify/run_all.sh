#!/bin/bash

main="$1"
mkdir -p output
rm -rf output/*

POINTS=0

dir=`dirname "$1"`

errorslist=$dir/errors.out
rm -f $errorslist

cd "$dir"
if [ -f yarn.lock ];
then
	yarn || npm install
else
	npm install
fi

passed=0
failed=0
total=0

rm alfy.js

echo '{ "node":true, "loopfunc": true, "esnext":true }' > .jshintrc
if [ ! -f `basename "$1"` ];
then
	echo "Your main.js file is missing"
elif ! jshint *.js;
then
	echo "Please review your code, you have jshint errors"
elif ! jison alfy.jison 
then
	echo "Please verify your grammar for errors"
else
	cd -
	for folder in alfy/*
	do
		if [ -d $folder ];
		then
			if [ -f "$folder"/run.txt ];
			then
				echo `head -n 1 "$folder"/run.txt` "(symbol, ast, error)"
				P1=`head -n 2 "$folder"/run.txt | tail -n 1 | cut -d " " -f 1`
				P2=`head -n 2 "$folder"/run.txt | tail -n 1 | cut -d " " -f 2`
				P3=`head -n 2 "$folder"/run.txt | tail -n 1 | cut -d " " -f 3`
			else
				echo `basename $folder` "(symbol, ast, error)"
				P1=10
				P2=10
				P3=10
			fi
			if [ $failed == 0 ] || ! (echo $folder | grep bonus &> /dev/null);
			then
				for file in "$folder"/*.alfy
				do
					inputfile=`pwd`/"$file"
					outputfile=output/`basename "$file"`.json
					originalfile="$file.json"
					errorsfile=output/`basename "$file"`.err
					title=`head -n 1 "$file" | grep '{' | cut -d '{' -f 2 | cut -d '}' -f 1` 
					if [ `echo -n "$title" | wc -c` -eq 0 ];
					then
						title=`basename $file`
					fi
					node "$1" "$inputfile" "$outputfile"
					strtitle="Verifying $title"
					printf '%s' "$strtitle"
					pad=$(printf '%0.1s' "."{1..60})
					padlength=75
					# echo $originalfile
					# echo $outputfile
					e=""
					str="("
					# Symbol
					echo "Symbol" > "$errorsfile"
					echo "-----------" >> "$errorsfile"
					if node verify.js "$originalfile" "$outputfile" "$P1" "symbol" >> "$errorsfile" 2>&1
					then
						p=$P1
						passed=$(($passed+1))
						POINTS=$(($POINTS+$P1))
					else
						p=0
						e="symbol "
					fi
					str=$str"$p""p, "
					# AST
					echo "AST" >> "$errorsfile"
					echo "-----------" >> "$errorsfile" 
					if node verify.js "$originalfile" "$outputfile" "$P2" "ast" >> "$errorsfile" 2>&1
					then
						p=$P2
						passed=$(($passed+1))
						POINTS=$(($POINTS+$P2))
					else
						p=0
						e=$e"ast "
					fi
					str=$str"$p""p, "
					# Error
					echo "Error" >> "$errorsfile"
					echo "-----------" >> "$errorsfile"
					if node verify.js "$originalfile" "$outputfile" "$P3" "error" >> "$errorsfile" 2>&1
					then
						p=$P3
						passed=$(($passed+1))
						POINTS=$(($POINTS+$P3))
					else
						p=0
						e=$e"error"
					fi
					str=$str"$p""p)"
					if [ "$e" == "" ]
					then
						str="ok "$str
					else
						diff --ignore-all-space -y --suppress-common-lines "$originalfile" "$outputfile" >> "$errorsfile" 2>&1
						#str="error (0p)"
						failed=$(($failed+1))
						echo "--------------" >> $errorslist 
						echo $strtitle >> $errorslist
						# head -10 "$errorsfile" >> $errorslist
						cat "$errorsfile" >> $errorslist
						str="error "$str
					fi
					total=$(($total+3))
					printf '%*.*s' 0 $((padlength - ${#strtitle} - ${#str} )) "$pad"
				    printf '%s\n' "$str"
				    #head -35 "$errorsfile"
				done
			else
				echo "Not verifying bonus, you have $failed failed tests"
			fi
		fi
	done	
fi

echo 'Tests: ' $passed '/' $total
echo 'Points: '$POINTS
echo 'Mark without penalities: '`echo $(($POINTS+10)) | sed 's/..$/.&/'`

if [ "$passed" != "$total" ];
then
	echo -e "Original tree						      | Your tree" 1>&2
	cat $errorslist 1>&2
fi
