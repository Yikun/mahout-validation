#!/bin/sh

echo -e '\033[44;37;5m=====================Begin=======================\033[0m'
if [ "$1" == "" ] ; then
  filename="clusteredPoints"
  echo "Warning: Using defualt data file name..."
else
  filename="$1"
fi

if [ ! -f $filename ]; then 
  echo "Sorry, The File [$filename] doesn't exist."
  exit
fi

echo -e "Get the data file name:\033[32;49;1m$filename\033[0m"

cat $filename | grep 'Key:' | awk -F '[' '{print $2}' | awk -F ']' '{print $1}' > current.dat
if diff "standard.dat" "current.dat" ; then 
  echo '-------------------------------------------------'
  echo -e '\033[32;49;1m   Data Match Test Result: Success, data match.\033[0m'
  echo '-------------------------------------------------'
  result1='Data Match Test Result: Success, data match.'
else
  echo '-------------------------------------------------'
  echo -e ' Data Match Test Result: Failed, data not match.\n Please see above for detail diff'
  echo '-------------------------------------------------'
  result1=' Data Match Test Result: Failed, data not match.'
fi

a=$(cat $filename | awk -F ': ' '{if(NF==7){print $2}}' | sort -u );
arr=($a)

echo -e '\033[32;49;1mThe Key is:\033[0m\n' ${arr[@]}
echo -e '\033[32;49;1mThe Count fo Key is:\033[0m\n' ${#arr[*]}
echo -en '\033[32;49;1mThe Clustering Results:\033[0m'

for data in ${arr[@]}
do
#
  echo -e "\n\033[32;49;1mKey: $data\033[0m"
  cat $filename |
  grep -n "Key: $data"|
  awk -F ':' '{print $1-2}' | tr '\n' ' '
done

echo -e '\n\033[44;37;5m====================Result=====================\033[0m'
echo -e '1.'$result1
echo -e '2. Accuracy Test Result:'

for data in ${arr[@]}
do
  cat $filename |
  grep "Key: $data" |        # grep the line include Key
  awk -F ' ' '{print $6}' > "data_$data"
  echo -e "--> Key: $data distance output into data_$data"
done

echo -e 'Key\tAverage\t\tVariance\tCount\tPercent(%)'

for data in ${arr[@]}
do
  #echo Key
  echo -ne "$data\t"
  
  #Accurate Average and echo Average
  cat $filename |     
  grep "Key: $data" |	     # grep the line include Key
  awk -F ' ' '{print $6}' |  # cat distance
  tr '\n' ' ' |		     # \n instead of ' ', convenient to acuurate average
  awk '{for(i=1;i<=NF;i++) total+=$i;ave=total/NF; print ave}' |
  tr '\n' '\t'
  echo -ne "\t"

  #Accurate Variance
  cat $filename |      # cat current
  grep "Key: $data" |        # grep the line include Key
  awk -F ' ' '{print $6}' |  # cat distance
  tr '\n' ' ' |              # \n instead of ' ', convenient to acuurate variance
  awk '{for(i=1;i<=NF;i++) total+=$i;ave=total/NF;for(i=1;i<=NF;i++) tmp+=(($i-ave)*($i-ave)); print tmp/NF}' |
  tr '\n' '\t'
  echo -ne "\t\c"  

  #Accurate Count
  Count=$(cat $filename |
  grep "Key: $data" |
  grep -n "Key: $data"|
  awk -F ':' '{print $1}' | wc -l)

  #Accurate Count
  echo  -ne "$Count\t"
  echo "scale=2;$Count/6"| bc
  
  #output 
  #cat $filename |grep "Key: $data" |awk -F ' ' '{print $6}'
done

echo -e '\033[44;37;5m=====================End=======================\033[0m'











