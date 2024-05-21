#!/bin/bash
# Programa realitzat per Christina Kaur Krishan

#./arbre.sh -u (unitats) -i (info) -d (directori) -s (fitxer)

unitats=b
info="-"
dir=`pwd`
dir_actual=`pwd`
fitxer="buit"

i=1
while [ $# -gt 0 ]
	do
		case $1 in
			"-u")
				unitats=$2;;
			"-i")
				info=$2;;
			"-d")
				dir=$2;;
			"-s")
				fitxer=$2;;
		esac
		shift
		shift
		let i=$i+1
	done


#$1 directori actual, $2 num fitxers, $3 mida de tots els fitxers
function mostrar_info() { #mostrar informació del directori
	echo -n "$1 $2 fitxers " #mostra per pantalla el nom i el nombre de fitxers de la carpeta
	
	#per mostrar la mida de la carpeta:
	mida=$3
	if [ $unitats == b ] 
		then echo -n $mida"B"
	elif [ $unitats == kb ]
		then let mida=$mida/1000
		echo -n $mida"KB"
	elif [ $unitats == mb ]
		then let mida=$mida/10000
		echo -n $mida"MB"
	else #elif [ $unitats == gb ]
		let mida=$mida/100000
		echo -n $mida"GB"
	fi 

	#mostrar info extra si cal:
	if [ $info == "inode" ] #número d'inode
		then echo " "$(ls -id `pwd` | tr -s ' ' | cut -d " " -f 1)
	elif [ $info == "permisos" ] #permisos
		then echo " "$(ls -ld `pwd` | tr -s ' ' | cut -d " " -f 1)
	elif [ $info == "usuari" ] #propietari:grup
		then echo " "$(ls -ld `pwd` | tr -s ' ' | cut -d " " -f 3):$(ls -ld `pwd` | tr -s ' ' | cut -d " " -f 4)
	elif [ $info == "data" ] #data de la darrera modificació
		then echo " "$(ls -ld `pwd` | tr -s ' ' | cut -d " " -f 7)/$(ls -ld `pwd` | tr -s ' ' | cut -d " " -f 6)
	else echo
	fi
}

#$1 directori actual, $2 num fitxers, $3 mida de tots els fitxers
function escriure_info_en_fitxer() { #escriure informació del directori en $fitxer
	echo -n "$1 $2 fitxers " >> "$dir_actual/$fitxer" #mostra per pantalla el nom i el nombre de fitxers de la carpeta

	#per mostrar la mida de la carpeta:
	mida=$3
	if [ $unitats == b ] 
		then echo -n $mida"B" >> "$dir_actual/$fitxer"
	elif [ $unitats == kb ]
		then let mida=$mida/1000
		echo -n $mida"KB" >> "$dir_actual/$fitxer"
	elif [ $unitats == mb ]
		then let mida=$mida/10000
		echo -n $mida"MB" >> "$dir_actual/$fitxer"
	else #elif [ $unitats == gb ]
		let mida=$mida/100000
		echo -n $mida"GB" >> "$dir_actual/$fitxer"
	fi
	
	#info extra
	if [ $info == "inode" ] #número d'inode
		then echo " "$(ls -id `pwd` | tr -s ' ' | cut -d " " -f 1) >> "$dir_actual/$fitxer"
	elif [ $info == "permisos" ] #permisos
		then echo " "$(ls -ld `pwd` | tr -s ' ' | cut -d " " -f 1) >> "$dir_actual/$fitxer"
	elif [ $info == "usuari" ] #propietari:grup
		then echo " "$(ls -ld `pwd` | tr -s ' ' | cut -d " " -f 3):$(ls -ld `pwd` | tr -s ' ' | cut -d " " -f 4) >> "$dir_actual/$fitxer"
	elif [ $info == "data" ] #data de la darrera modificació
		then echo " "$(ls -ld `pwd` | tr -s ' ' | cut -d " " -f 7)/$(ls -ld `pwd` | tr -s ' ' | cut -d " " -f 6) >> "$dir_actual/$fitxer"
	else echo >> "$dir_actual/$fitxer"
	fi
}

function mostrar_arbre() { #mostrar carpertes del directori
	cont=0 #contador de fitxers
	mida=0 #mida de tots els fitxers

	cd $3 

	#this és l'arxiu actual
	for this in `ls` #recorregut de tot el que hi ha en el directori actual i si és un fitxer suma la mida d'aquest a $mida 
	do
		if [[ -f $this ]]
			then let cont=$cont+1
			#mida fitxer $this
			if [[ -x "$this" ]]
				then let mida=$mida+$(ls -l $this | tr -s ' ' | cut -d " " -f 5)
			fi
		fi
	done

	if [ $fitxer == "buit" ] #mostrar tota la info del directori principal
		then mostrar_info `pwd` $cont $mida
	else escriure_info_en_fitxer `pwd` $cont $mida
	fi

	for this in `ls` #recorregut de tot el que hi ha en el directori actual i si és una carpeta es crida la mateixa funció per mostrar la info d'aquesta
	do
		if [[ -d $this ]] && [ $this != `pwd` ]
			then if ! [[ -x "$this" ]]
				then 
				if [ $fitxer == "buit" ]
					then echo `pwd`/$this "*permission denied*"
				else echo `pwd`/$this "*permission denied*" >> "$dir_actual/$fitxer"
				fi
			else
				mostrar_arbre $unitats $info $this $fitxer
				cd ".."
			fi
		fi
	done
}

mostrar_arbre $unitats $info $dir $fitxer
