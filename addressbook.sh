#!/usr/bin/env bash

# DESCRIPTION:
# 

address_book="test.txt"

addEntry()
{
 echo -n "Enter user's full name (example: John Smith): "
 read name
 echo -n "Enter user's phone number (example: 12345): "
 read phone
 echo -n "Enter user's email (example: john@example.com): "
 read email

 echo "$name:$phone:$email" >> $address_book
}

searchEntry()
{
 echo -n "Please enter search text: "
 read text
 RESULT=$(grep $text $address_book)
 echo '****************************************************'
 echo "$RESULT" | awk -F":" '{ print "----------------------------------------------------";
                               print "\t Name [ " $1 " ]";
                               print "\t Phone [ " $2 " ]";
                               print "\t Email [ " $3 " ]";
                              } END { print "----------------------------------------------------" }'
 echo '****************************************************'
 echo
 [ -z "$RESULT" ] && echo "Record not found" && return 2
}

removeEntry()
{
 searchEntry

 [ $(echo $?) -eq 2 ] && return 2

 declare -a RECORDSET

 for line in $RESULT; do
  RECORDSET+=("$line")
 done

 [ "${#RECORDSET[@]}" -gt 1 ] && echo -n "Please type Name of the person which record you want to remove: " && \
 read name && FOUND=$(printf '%s\n' "${RECORDSET[@]}" | grep "$name")

 [ -z "$FOUND" ] && [ "$(echo $RESULT | tr ' ' '\n' | wc -l)" -gt 1 ] && echo "Name is incorrect" && \
 echo -n "Please type Name of the person which record you want to remove: " && \
 read name && FOUND=$(printf '%s\n' "${RECORDSET[@]}" | grep "$name")

 echo -n "Do you really want to remove this record? (Y/N): "
 read answer
 answer=`echo $answer | tr [a-z] [A-Z]`

 if [ "$answer" == "Y" ] && [ ! -z "$FOUND" ]; then
   sed -i "/$FOUND/d" $address_book && echo "Record removed successfully"
   FOUND=""
 elif [ "$answer" == "Y" ] && [ -z "$FOUND" ]; then
   sed -i "/$RESULT/d" $address_book && echo "Record removed successfully"
   RESULT=""
 else
   return 2
 fi
}

while true; do
 echo -n "Please choose action: add, search, remove, q (to quit program): "
 read input
 [ "$input" == "add" ] && addEntry
 [ "$input" == "search" ] && searchEntry
 [ "$input" == "remove" ] && removeEntry
 [ "$input" == 'q' ] && exit 0
done

