#!/bin/awk

BEGIN {
	FS=";";
	RS="\n";
	
	cantviajes=0;
	cantpasajeros=0;
	montototal=0;
}
{
	cantviajes=cantviajes + 1;
	if ($5 ~ /^[0-9]+$/)
		cantpasajeros=cantpasajeros + $5;
	if ($6 ~ /^[0-9]+$/)
		montototal=montototal + $6;

}
END {
	var=FILENAME;
	n=split (var,a,/\//);
	var1=a[n];
	tren=substr (var1,2,2);
	printf("%s,%s,%s,%s",tren,cantviajes,cantpasajeros,montototal);
}
