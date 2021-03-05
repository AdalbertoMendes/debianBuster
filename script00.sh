#!/bin/bash
# Autor: Adalberto Mendes
# Data de criação: 09/10/2020
# Data de atualização:
# Versão: 0.1
# Testado e homologado para a versão do Debian 10 - Buster 
# Kernel >= 4.19.x
#
# Instalação dos pacotes principais para a primeira etapa
#
# Acertar os arquivos da pasta conf:
#	bash
#	hosts
#
# Atualização das listas do Apt-Get
# Atualização dos Aplicativos Instalados
# Atualização da Distribuição Ubuntu Server (Kernel)
# Auto-Limpeza do Apt-Get
# Limpando o repositório Local do Apt-Get
# Acertando bash
# Reiniciando o Servidor
#
# Utilizar o comando: sudo -i para executar o script
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

if [ "$USUARIO" == "0" ]
then
	if [ "$DEBIAN" == "10" ]
		then
			if [ "$KERNEL" == "4.19" ]
				then
					 clear
					 echo -e "Usuário é `whoami`, continuando a executar o Script-00.sh"
					 echo
					 echo -e "01. Atualização das listas do Apt-Get"
					 echo -e "02. Atualização dos Aplicativos Instalados"
					 echo -e "03. Atualização da Distribuição Ubuntu Server (Kernel)"
					 echo -e "04. Autoremoção dos Aplicativos do Apt-Get"
					 echo -e "05. Limpando o repositório Local do Apt-Get (Cache)"
					 echo -e "06. Acertando bash"
					 echo
					 echo -e "Após o término o Servidor será reinicializado"
					 echo
					 echo  ============================================================ >> $LOG

					 echo -e "Qual o nome do Servidor?"
					read Hostname
					 
    				echo -e "Acertando IP fixo"				
					# Backup do script interfaces
					mv /etc/network/interfaces /etc/network/interfaces.OLD 
					cp -v conf/interfaces /etc/network/interfaces
					ping google.com -c 2
					echo -e "Se ping der certo então digite Enter, se não Ctrl+C e verifique o arquivo /etc/network/interfaces" 					
					read

                    echo -e "Atualizando as Listas do Apt-Get (apt-get update), aguarde..."
                    	#Exportando a variável do Debian Frontend Noninteractive para não solicitar interação com o usuário
                    	export DEBIAN_FRONTEND=noninteractive
                    	#Atualizando as listas do apt-get
                    	apt-get update &>> $LOG
                    	echo -e "Listas Atualizadas com Sucesso!!!, continuando o script..."
                    echo
                    echo  ============================================================ >> $LOG
                    echo -e "Atualização dos Aplicativos Instalados (apt-get upgrade), aguarde..."
                    	#Fazendo a atualização de todos os pacotes instalados no servidor
                    	apt-get -o Dpkg::Options::="--force-confold" upgrade -q -y --force-yes &>> $LOG
                    	echo -e "Sistema Atualizado com Sucesso!!!, continuando o script..."
                    echo
                    echo  ============================================================ >> $LOG
                    echo -e "Atualização da Distribuição Ubuntu Server Kernel (apt-get dist-upgrade), aguarde..."
                    echo -e "Versão do Kernel atual: `uname -r`"
                    	#Fazendo a atualização do Kernel
                    	apt-get -o Dpkg::Options::="--force-confold" dist-upgrade -q -y --force-yes &>> $LOG
                    	echo
                    	echo -e "Listando os Kernel instalados"
                    	#Listando as imagens dos Kernel instalados
                    	dpkg --list | grep linux-image | cut -d" " -f3
                    	echo -e "Kernel Atualizado com Sucesso!!!, continuando o script..."
                    echo
                    echo ============================================================ >> $LOG
                    echo -e "Autoremoção dos Aplicativos desnecessários instalados (apt-get autoremove), aguarde..."
                    	#Removendo aplicativos que não estão sendo mais usados
                    	apt-get -y autoremove &>> $LOG
                    	echo -e "Remoção feita com Sucesso!!!, continuando o script..."
                    	echo
                    echo ============================================================ >> $LOG
                    echo -e "Limpando o Cache do Apt-Get (download dos arquivos *.deb | apt-get autoclean e apt-get clean), aguarde..."
                    	#Limpando o diretório de cache do apt-get
                    	apt-get autoclean &>> $LOG
                    	apt-get clean &>> $LOG
                    	echo -e "Cache Limpo com Sucesso!!!, continuando o script..."
                    	echo
                    echo ============================================================ >> $LOG
			echo -e "Configurando Bash"
			mv -v /root/.bashrc /root/.bash.OLD >> $LOG
			cp -v conf/bashrc /root/.bashrc >> $LOG
			echo -e "Bach configurado!!!, continuando o script..."
			echo
                    echo ============================================================ >> $LOG
			hostnamectl set-hostname $Hostname
			mv /etc/hosts /etc/hosts.OLD
			cp -v conf/hosts /etc/hosts
			hostname -f
			echo -e "Hostname configurado!!!, continuando o script..."
                    echo
                    echo ============================================================ >> $LOG
                    echo -e "Configurando app vim"
                    	systemctl restart networking.service
                    	apt-get install vim >> $LOG
                    	cp -v conf/vimrc /root/.vimrc >> $LOG
			echo -e "Vim instalado e Configurado!!!"
                    echo ============================================================ >> $LOG
		    echo
		    echo -e "Fim do Script-00.sh em: `date`" >> $LOG
					echo
					echo -e "Atualização das Listas do Apt-Get, Atualização dos Aplicativos e Atualização do Kernel Feito com Sucesso!!!!!"
					echo
					# Script para calcular o tempo gasto para a execução do script-00.sh
						DATAFINAL=`date +%s`
						SOMA=`expr $DATAFINAL - $DATAINICIAL`
						RESULTADO=`expr 10800 + $SOMA`
						TEMPO=`date -d @$RESULTADO +%H:%M:%S`
					echo -e "Tempo gasto para execução do script-00.sh: $TEMPO"
					echo -e "Pressione <Enter> para reinicializar o servidor: `hostname`"
					read
					sleep 2
					reboot
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

