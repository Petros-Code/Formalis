#!/bin/bash

LOG_FILE="/var/log/certbot-renew.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] Lancement du renouvellement du certificat..." >> "$LOG_FILE"

certbot renew --quiet >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
    echo "[$DATE] Renouvellement réussi. Redémarrage de NGINX..." >> "$LOG_FILE"
    docker restart formalis_nginx >> "$LOG_FILE" 2>&1
else
    echo "[$DATE] Echec du renouvellement. Vérifiez les logs Certbot." >> "$LOG_FILE"
fi
