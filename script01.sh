#!/bin/bash
# Autor: Adalberto Mendes
# Data de criação: 09/10/2020
# Data de atualização:
# Versão: 0.1
# Testado e homologado para a versão do Debian 10 - Buster 
# Kernel >= 4.19.x
#
# Instalação do Samba e provisionamento como DC02
#
# Orientações:
#	Antes de executar anote o nome do host do DC01 e do dominio
#	Qualquer erro aperte Ctrl + C
#
# Acertar os arquivos da pasta conf:
#	resolv.conf
#	smb.conf (Deixar o mais próximo possível do DC01)
#	
# Referencia:
#	https://www.server-world.info/en/note?os=Ubuntu_18.04&p=samba&f=4
#
# Caminho para o Log do Script-00.sh
LOG="/var/log/script-00.log"
#
# Variável da Data Inicial para calcular tempo de execução do Script
DATAINICIAL=`date +%s`
#
# Validando o ambiente, verificando se o usuário e "root"
USUARIO=`id -u`
DEBIAN=`lsb_release -rs`
KERNEL=`uname -r | cut -d'.' -f1,2`
HOSTNAME=`hostname`
FDQN=`hostname -f`
echo -e "Qual Dominio?"
read DOMINIO
echo
#echo -e "Qual o Hostname do DC01"
#read HOSTDOMINIO 

if [ "$USUARIO" == "0" ]
then
	if [ "$DEBIAN" == "10" ]
		then
			if [ "$KERNEL" == "4.19" ]
				then
					 clear
					 echo -e "Usuário é `whoami`, continuando a executar o Script-00.sh"
					 echo
					 echo -e "01. Instalando Samba como DC02"
					 echo
					 echo -e "Após o término o Servidor deverá ser reiniciado"
					 echo
					 echo  ============================================================ >> $LOG

					# Acertando roteamento
					chattr -i /etc/resolv.conf
					mv  /etc/resolv.conf /etc/resolv.conf.OLD
					cp  -v conf/resolv.conf /etc/resolv.conf >> $LOG
					chattr +i /etc/resolv.conf
                    echo -e "Acertando resolv.conf!!!, continuando o script..."
                    echo
                    echo  ============================================================ >> $LOG

					# Instalar Servidor NTP
					apt-get install ntp ntp-doc ntpdate dnsutils >> $LOG
					echo -e "Instalado Servidor NTP!!!, continuando o script..."
					echo
					echo  ============================================================ >> $LOG

					# Instalar Samba
					apt-get install samba krb5-config winbind smbclient smbclient krb5-user libpam-winbind libnss-winbind >> $LOG
					# Fazer cópia do arquivo krb5.conf
					mv /etc/krb5.conf /etc/krb5.conf.OLD
					cp -v conf/krb5.conf /etc/krb5.conf >> $LOG
					echo
					echo -e "Criando Tiket no Kerberos." 
					cp -v /var/lib/samba/private/krb5.conf /etc/krb5.conf $LOG
					kinit administrator
					klist
					rm -Rf /etc/samba/smb.conf
					# Provisionando
					samba-tool domain join $DOMINIO DC -U administrator --realm=$DOMINIO --dns-backend=SAMBA_INTERNAL --option="bind interfaces only=yes" --option='idmap_ldb:use rfc2307=yes'
					systemctl stop smbd nmbd winbind systemd-resolved 
					systemctl disable smbd nmbd winbind systemd-resolved 
					systemctl unmask samba-ad-dc
					systemctl start samba-ad-dc
					systemctl enable samba-ad-dc 
	                echo -e "Instalado Samba!!!, continuando o script..."
                    echo
                    echo  ============================================================ >> $LOG
				
					echo -e " ATENÇÃO "
					echo 
					echo -e "Fazer os seguintes testes ao final do script, depois REINICIAR."
					echo -e "$ nslookup DC01.DOMINIO"
					echo -e "$ nslookup"
                    echo -e "> set type=SRV"
                    echo -e "> _ldap._tcp.DOMINIO."
                    echo -e "> _kerberos._udp.DOMINIO."
 					echo 	
     				echo -e "Fim do Script-01.sh em: `date`" >> $LOG
					echo
					# Script para calcular o tempo gasto para a execução do script-00.sh
						DATAFINAL=`date +%s`
						SOMA=`expr $DATAFINAL - $DATAINICIAL`
						RESULTADO=`expr 10800 + $SOMA`
						TEMPO=`date -d @$RESULTADO +%H:%M:%S`
					echo -e "Tempo gasto para execução do script-00.sh: $TEMPO"
					echo -e "Pressione <Enter>, saia do script e execute as linhas acima para testes.: `hostname`"
					read
				#	reboot
					else
						echo -e "Versão do Kernel: $KERNEL não homologada para esse script, versão: >= 4.4 "
						echo -e "Pressione <Enter> para finalizar o script"
						read
			fi
	 	 else
			 echo -e "Distribuição GNU/Linux: `lsb_release -is` não homologada para esse script, versão: $UBUNTU"
			 echo -e "Pressione <Enter> para finalizar o script"
			 read
	fi
else
	 echo -e "Usuário não é ROOT, execute o comando com a opção: sudo -i <Enter> depois digite a senha do usuário `whoami`"
	 echo -e "Pressione <Enter> para finalizar o script"
	read
fi

