#!/bin/bash
archv=$(uname -vm) #Uname da informacion del sistema. -v version kernel y -m arquitectura
CPU=$(grep "physical id" /proc/cpuinfo | uniq | wc -l)  #Cuento el numero de physical id distintos que aparecen en la info
                                                        #de procesadores, cada uno corresponde a una CPU fisica.
														#Estas pueden tener varios nucleos, y varios procesadores virtuales cada uno.
														#Mas proces que nucleos --> Hyperthreadimng
vCPU=$(grep "^processor" /proc/cpuinfo | wc -l)     #Cuento el numero de procesadores, es decir, el numero de vcpus. grep "^ " empieza por esto
tRAM=$(free --mega | awk '$1 == "Mem:" {print $2}') #Free enseña la memoria. Awk columna 2, solo cuando columna 1 es "Mem:"
uRAM=$(free --mega | awk '$1 == "Mem:" {print $3}')
rRAM=$(free | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')   #No tengo que especificar la unidad, porque voy a dividir
                                                                #Utilizo printf para la precision del porcentaje (decimales)
																#%f floating, .2 es precision de dos números.
tmdsk=$(df -Bm --total | awk '$1 == "total" {print $2}' | sed 's/M//')	 	#df enseña espacio disco, -Bm selecciona unidades a Megas
umdsk=$(df -Bm --total | awk '$1 == "total" {print $3}' | sed 's/M//')		#sed 'sustituye/estevalor/porlanada/'
rmdsk=$(df -Bm --total | awk '$1 == "total" {printf("%.2f"), $3/$2*100}')	
rCPU=$(top -bn1 | awk '$1 == "%Cpu(s):" {printf("%.2f"), $2 +$4}') #top lista los procesos en tiempo real, bn1 solo actualiza una vez
																   #Cojo las col2 y 4, que tienen cpu de usuario y de proc inactivos
lstb=$(who -b | awk '{print $3 " " $4}')	#who -b da el last reboot. Cojo fecha, espacio, y hora.
nLVM=$(lsblk | grep "lvm" | wc -l)	#Cuento el numero de particiones que tengan el lvm. Si es mayor que cero, esta activo.
LVM=$(if [ $nLVM -eq 0 ]; then echo No; else echo Yes; fi) #Estructura ifs, terminada en fi. -eq 0 es == 0. Espacio entre if y condicion importante.
ncon=$(ss -s | awk '$1 == "TCP:" {print $4}' | sed 's/,//') #ss -s enseña conexiones. Me quedo con las established y quito la coma.
nuser=$(users | wc -w)	#Enseña usuarios en misma linea, asi que cuento palabras.
ip=$(hostname -I)
mac=$(ip link show | awk '$1 == "link/ether" {print $2}') #Enseño ips, hay varios metodos. Cojo el ether, que es la MAC.
nsudcmd=$(journalctl _COMM=sudo | grep "COMMAND" | wc -l) #Puedo leer el log, y filtro los comandos sudo. De ahi me quedo con
														  #las lineas que realmente son ejecuciones de comando y las cuento.
wall -n "Architecture: $archv			#Wall envia un mensaje por pantalla. -n elimina el banner inicial
#CPU Physical: $CPU
#vCPU: $vCPU
#Memory Usage: $uRAM/${tRAM}MB ($rRAM%)
#Disk Usage: %umdsk/${tmdsk}MB ($rmdsk%)
#CPU Load: $rCPU%
#Last Boot_ $lstb
#LVM Use: $LVM
#Connexions TCP: $mcpm ESTABLISHED
#User Log: $nuser
#Network: IPv4 $ip // MAC $mac
#Sudo: $nsudcmd commands executed"
