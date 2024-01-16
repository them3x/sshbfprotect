#!/bin/bash

while true; do
        echo "Verificando IPs que tentaram login no SSH"

        journalctl _COMM=sshd | grep "Failed password" | cut -d " " -f 11 > /tmp/ips_fails
        cat /tmp/ips_fails | sort | uniq -c | awk '$1 > 2 {print $2}' > /tmp/toips_block

        for i in $(cat /tmp/toips_block);do
                echo $i
                if grep -q "$i" /tmp/ips_ja_bloqueado; then
                        echo "IP $i ja bloqueado"
                else
                        echo "$i" >> /tmp/ips_ja_bloqueado
                        echo "Bloqueando IP $i"
                        iptables -A INPUT -s $i -p tcp -j DROP
                fi
        done

        sleep 10
done
