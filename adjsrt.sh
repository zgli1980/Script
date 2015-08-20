#!/bin/sh
offset=$1
shift
awk -v offset=$offset '
BEGIN{
	FS="[ :,]+"
}
/^[0-9][0-9]:[0-9]*/ {
	ST=toT($1,$2,$3)+offset;
	ST1=int(ST/3600);
	ST2=int((ST-ST1*3600)/60);
	ST3=ST%60;
	ET=toT($6,$7,$8)+offset;
	ET1=int(ET/3600);
	ET2=int((ET-ET1*3600)/60);
	ET3=ET%60;
	printf("%02d:%02d:%02d,%03d --> %02d:%02d:%02d,%03d\n",
		ST1,ST2,ST3,$4,ET1,ET2,ET3,$9);
}
$0 !~ /^[0-9][0-9]:[0-9]*/ {
	print $0
}
 
function toT( hour, min , sec ){
	return hour*3600 + min*60 + sec
}
' $*