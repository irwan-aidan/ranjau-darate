#!/bin/bash
# Shared under GNU v3

clear

	#Cek user root
	if [ "$EUID" -ne "0" ]
	then
		echo "Login root dulu Boss"
		exit
	fi

	#Choose External Port
	echo "Masukan port yang mau di open"
	read -r "ex port"

	#Find vpn address
	echo "Masukan IP VPS yang ingin Anda port pointing"
	read "vpsip"

	#Find Internal port
	echo "Masukan port internal"
	read "in port"

	#What protocol

	echo "Masukan protocol tcp / udp / tcp/udp"
	read protocol
	if [ \( "$protocol" == "tcp" \) -o \( "$protocol" == "udp" \) -o \( "$protocol" == "tcp/udp" \) ]
	then
		echo "Selesai"
	else
		echo "Maaf, anda harus menetukan protocol !!!"
		exit
	fi

	#Periksa kembali dengan pengguna apakah ini konfigurasi yang benar
	echo "Apakah konfigurasi ini sudah benar ?"
	echo "$vpsip:$intport dengan $protocol $extport sebagai port external? [y/n]"
	read "konfirmasi"

	#Execution
	if [ "$konfirmasi" == "y" ]
	then

		if [ "$protocol" == "tcp" ]
		then
			iptables -A PREROUTING -t nat -i  ens4 -p tcp --dport "$extport" -j DNAT --to "$vpsip":"$intport"
			iptables -A FORWARD -p tcp -d "$vpsip" --dport "$extport" -j ACCEPT
		fi

		if [ "$protocol" == "udp" ]
		then
			iptables -A PREROUTING -t nat -i ens4 -p udp --dport "$extport" -j DNAT --to "$vpsip":"$intport"
			iptables -A FORWARD -p udp -d "$vpsip" --dport "$extport" -j ACCEPT
		fi

		if [ "$protocol" == "tcp/udp" ]
		then
			iptables -A PREROUTING -t nat -i  ens4 -p tcp --dport "$extport" -j DNAT --to "$vpsip":"$intport"
			iptables -A FORWARD -p tcp -d "$vpsip" --dport "$extport" -j ACCEPT
			iptables -A PREROUTING -t nat -i ens4 -p udp --dport "$extport" -j DNAT --to "$vpsip":"$intport"
			iptables -A FORWARD -p udp -d "$vpsip" --dport "$extport" -j ACCEPT
		fi

	else
		echo "Script Terminating"
		exit
	fi

	#Asking To Save rules
	echo "Apakah Anda ingin menyimpan aturan atau menghapusnya saat reboot? [y/n]"
	read "simpan"

	if [ "$simpan" == "y" ]
	then
		echo "Menyimpan"
		iptables-save > /etc/iptables.up.rules
		iptables-restore -t < /etc/iptables.up.rules
		netfilter-persistent save
		netfilter-persistent reload
		systemctl daemon-reload
	fi

	#Reminder to port foward server side
	echo "Selesai! Ingatlah untuk menambahkan aturan firewall untuk $extport $protocol sisi server"
	
