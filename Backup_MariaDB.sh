#!/bin/bash -xe
###################################################################
# Nome : Backup_MariaDB.sh
# Script para Backup dos dados do Banco MariaDB  #
# Criação : 09/04/2019 - Ricardo Vieira de Souza #
# E-mail  ricardo@servidorcasa.com.br
#Versão 1.0
#
#Esse script tem a finalizade de realizar Backup de dos os bancos de dados
#dentro do mysql e depois compactar e enviar para um servidor de backup que fica na mesma rede


                                              #
###################################################################

# Changelog


##### Variaveis
 DATA=`date +%Y%m%d_%H_%M_%S`

 DIR_BACKUP=/home/rvs/teste/ #  Define o diretório de backup
 SENHA="senha@123Servidor"
 USER="souza"
 DIR_DEST_BACKUP=$DIR_BACKUP$DATA
 LOGS=/var/log/script.log   #envia log para o arquivo script.log

###################################################################
rm -rf /home/rvs/teste/20*
rm -rf /home/shell_script/*.gz 
##### Rotinas secundarias
mkdir -p $DIR_BACKUP/$DATA # Cria o diretório de backup diário
echo "MYSQL">>$LOGS
echo "Iniciando backup do banco de dados" >>$LOGS
##################################################################
#####

# função que executa o backup
executa_backup(){
echo "Inicio do backup $DATA"
 #Recebe os nomes dos bancos de dados na maquina destino
 BANCOS=$(mysql -u $USER -p$SENHA -e "show databases")
 #retira palavra database
 #BANCOS=${BANCOS:9:${#BANCOS}}

 CONT=0

#inicia o laço de execução dos backups

for banco in $BANCOS
 do
 if [ $CONT -ne 0 ]; then    # ignora o primeiro item do array, cujo conteudo é "databases"
     NOME="backup_my_"$banco".sql"


    echo "Iniciando backup do banco de dados [$banco]"
   # comando que realmente executa o dump do banco de dados
   mysqldump --hex-blob --lock-all-tables -u $USER -p$SENHA --databases $banco > $DIR_DEST_BACKUP/$NOME


   # verifica que se o comando foi bem sucedido ou nao.
   if [ $? -eq 0 ]; then
      echo "$DATA $0 Backup Banco de dados [$banco] completo" >>$LOGS


   else
      echo "$DATA $0 ERRO ao realizar o Backup do Banco de dados [$banco]" >> $LOGS
   fi

fi
 CONT=`expr $CONT + 1`
 done


DATA=`date +%Y_%m_%d__%H_%M`
DATA1=`date +%Y_%m_%d__%H`
echo "Final do backup: $DATA" >>$LOGS
echo "" >>$LOGS
}

executa_backup 2>> $DIR_BACKUP/$DATA/backup.log 1>> $DIR_BACKUP/$DATA/backup.log

tar czvf $DATA.tar.gz $DIR_BACKUP    #compactando arquivo para envio para servidor de backuṕ
scp $DATA1* servidor1:/home/servidor1/MEGA #copiando os aquivos para servidor de backup



###################################################################

