#!/bin/bash

##########################################################################################################
#                                                                                                        #
#                  Shell Script para Restart do Media Proxy em caso de Erro                              #
#                                                                                                        #
# Author:                         Rômulo Silva                                                           #
# Date Developer:                 11-09-2019                                                             #
# Version:                        1.1                                                                    #
#                                                                                                        #
#  Este Script tem a finalidade de ficar checando de 1 em 1 segundo o arquivo /var/log/syslog em         #
#  busca de erros do sistema mediaproxy-relay.                                                           #
#                                                                                                        #
#  O Script busca pelas palavras CRITICAL e ERROR que são gerados pelo log do sistema mediaproxy-relay,  #
#  e se encontrar qualquer um dos erros ele mata o processo do mediaproxy-relay e restarta o sistema     #
#  mediaproxy-relay                                                                                      #
#                                                                                                        #
#  Este script pode ser utilizado para outros sistema e outros erros, com pequenas modificações          # 
#                                                                                                        #
##########################################################################################################

# Looping infinito para o script ficar executando sem parar
while :
do

 # Atribui o valor de 1 a variavel linha
 linha=1
 data=$(date "+%d%H%M%S")

 # Limpa a tela 
 clear

 # Grava Arquivo log.txt com as informações do erro CRITICAL
 grep "CRITICAL" /var/log/syslog | cut -d"[" -f1 --output-delimiter="4" > log.txt 
 
 # Grava Arquivo log1.txt com as informações do erro ERROR
 grep "ERROR" /var/log/syslog | cut -d"[" -f1 --output-delimiter="4" > log1.txt


 # Retira as palavras, os : e os espaços em branco do arquivo log.txt
 sed -i 's/mediaproxy/ /;s/media-relay/ /;s/mediaproxy-relay/ /;s/systemd/ /;s/CRON/ /;s/ntpd/ /;s/://g;s/.\{2,4\}//;s/ //g' log.txt
 
 # Retira as palavras, os : e os espaços em branco do arquivo log1.txt
 sed -i 's/mediaproxy/ /;s/media-relay/ /;s/mediaproxy-relay/ /;s/systemd/ /;s/CRON/ /;s/ntpd/ /;s/://g;s/.\{2,4\}//;s/ //g' log1.txt 

 # Adiciona o arquivo log.txt no descritor 3
 exec 3< log.txt

 # Loop que trata os dados do arquivo log.txt
 while read arq <&3; do

   # Pega data e hora do arquivo log.txt
   dataarq=$(cat log.txt | sed -n "$linha p")
   
   # Pega data e hora do arquivo log1.txt
   dataarq1=$(cat log1.txt | sed -n "$linha p")

   # Compara se as datas dos arquivos log.txt e log1.txt são iguais a data do computador 
   if [ "$dataarq" -eq "$data" ] || [ "$dataarq"1 -eq "$data" ];
   then 
   
    # Mata o processo media-relay
    killall -9 media-relay

    # Da Stop no mediaproxy-relay
    /etc/init.d/mediaproxy-relay stop

    # Da Start no mediaproxy-relay
    /etc/init.d/mediaproxy-relay start

    # Grava a data que ocorreu o evento no arquivo data.txt
    echo "$data" > data.txt

   fi

    # Inclementa +1 na variavel linha em cada loopin
    let linha=$linha+1

 done

# Limpa o descritor 3
 exec 3<&- 

 # Remove os arquivos criados pelo script
 rm log.txt log1.txt

 # Espera por 1 segundo 
 sleep 1

done
