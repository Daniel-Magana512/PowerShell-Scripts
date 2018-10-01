#!/bin/awk

BEGIN {
	FS=";";
	RS="\n";
	nocumple=0;
	dias["Lunes"]=1;
	dias["Martes"]=2;
	dias["Miercoles"]=3;
	dias["Jueves"]=4;
	dias["Viernes"]=5;
	dias["Sabado"]=6;
	dias["Domingo"]=7;
}

FNR>1 {
	time1=0;
	time2=0;
	if(NR == FNR){ #primer archivo VIAJE
	   n[$1] = $4; #ciudad horario
	   d[$1] = $2; #ciudad dia
	} else {		#luego segundo archivo RUTA
		#printf("%s  %s\n", d[$1], $2);
		#printf("%d %d\n",dias[d[$1]] , dias[$2]);
		if(dias[d[$1]] > dias[$2]){ #deberia caer un Lunes y cayo un Domingo - VIAJE > RUTA
			if( (dias[d[$1]] - dias[$2]) == 6){ #deberia caer un lunes pero cayo un domingo
				nocumple = nocumple + 1; 
				split (n[$1],arr,/:/);
				time1 = 86400 - (3600*arr[1] + 60*arr[2]);
				split ($3,arr2,/:/);
				time2 = 3600*arr2[1] + 60*arr2[2];
			
				e[$1] = (time1 + time2)/60;
				#printf("%s %d", $1, e[$1]);
				f[$1] = 1; #se adelanto
			}
			else{ #VIAJE atrasado contra RUTA - deberia caer un Martes y cae Miercoles
				nocumple = nocumple + 1; 
				split (n[$1],arr,/:/);
				time1 = 3600*arr[1] + 60*arr[2];
				split ($3,arr2,/:/);
				time2 = 86400 - (3600*arr2[1] + 60*arr2[2]);
			
				e[$1] = (time1 + time2)/60;
				f[$1] = -1; #se atraso
			}

		}

		if(dias[d[$1]] < dias[$2]){ #deberia caer un Miercoles y cae Martes -  VIAJE < RUTA
			if( (dias[d[$1]] - dias[$2]) == -6){ #deberas caer un domingo pero cayo un lunes
				nocumple = nocumple + 1; 
				split (n[$1],arr,/:/);
				time1 = 3600*arr[1] + 60*arr[2];
				split ($3,arr2,/:/);
				time2 = 86400 - (3600*arr2[1] + 60*arr2[2]);
			
				e[$1] = (time1 + time2)/60;
				f[$1] = -1; #se atraso
			}
			else{ #VIAJE adelantado contra RUTA - deberia caer un Jueves y cae Miercoles
				nocumple = nocumple + 1; 
				split (n[$1],arr,/:/);
				time1 = 86400 - (3600*arr[1] + 60*arr[2]);
				split ($3,arr2,/:/);
				time2 = 3600*arr2[1] + 60*arr2[2];
			
				e[$1] = (time1 + time2)/60;
				f[$1] = 1; #se adelanto
			}
		}

		if(dias[d[$1]] == dias[$2]){
			if(n[$1] != $3){
				nocumple = nocumple + 1; 
				split (n[$1],arr,/:/);
				time1 = 3600*arr[1] + 60*arr[2];
				split ($3,arr2,/:/);
				time2 = 3600*arr2[1] + 60*arr2[2];
			
				e[$1] = (time1 - time2)/60;
				if(e[$1] > 0){ #se atraso
					f[$1] = -1;
				}
				if(e[$1] < 0){ #se adelanto
					f[$1] = 1;
					e[$1] = e[$1]*-1
				}
			}
			else{
				e[$1] = 0;
			}
		}
	   
	}
}
END{

	if( nocumple == 0 )
	{
	printf("El tren %s cumplio con todos los horarios. \n",tren); #falta hallar numero de tren
	}
	else	
	{	for(key in e) #ciudad y tiempos
		{	
			horas=0;
			minutos=e[key];

			while(minutos >= 60){
				minutos-=60;
				horas+=1;
			}			

			if(e[key] == 0)
				printf("El horario de %s fue cumplido. \n",key);
			else if(f[key] < 0 )
			{
				printf("El horario de %s se atraso %d horas con %d minutos. \n", key, horas,minutos);
			} else {
				printf("El horario de %s se adelanto %d horas con %d minutos. \n", key, horas,minutos);
			}
		}
     }
}
