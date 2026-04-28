# Documentation opérationnelle — Formalis

## 1. Prérequis (serveur Linux)

Avant de lancer la stack, s'assurer que les outils suivants sont installés sur l'hôte :

```bash
# Vérifier Docker
docker --version
docker compose version

# Vérifier Certbot
certbot --version

# Installer Certbot si absent (Debian/Ubuntu)
sudo apt update && sudo apt install certbot
```

---

## 2. Certificat SSL

Comme `formation.local` est un domaine local, Let's Encrypt ne peut pas délivrer de certificat public. On génère un certificat **auto-signé** avec OpenSSL, placé dans la structure attendue par Certbot.

```bash
# Créer le dossier attendu par NGINX
sudo mkdir -p /etc/letsencrypt/live/formation.local

# Générer un certificat auto-signé (valable 365 jours)
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/letsencrypt/live/formation.local/privkey.pem \
  -out /etc/letsencrypt/live/formation.local/fullchain.pem \
  -subj "/CN=formation.local"
```

> Le navigateur affichera un avertissement de sécurité : c'est normal pour un certificat auto-signé.

---

## 3. Variables d'environnement

Copier le fichier `.env.example` en `.env` et renseigner les valeurs :

```bash
cp .env.example .env
```

Ne jamais committer le fichier `.env` (déjà dans le `.gitignore`).

---

## 4. Commandes Docker

### Construire les images
```bash
docker compose build
```

### Lancer la stack en mode détaché
```bash
docker compose up -d
```

### Vérifier l'état des conteneurs
```bash
docker compose ps
```

### Consulter les logs d'un service
```bash
docker compose logs node-app
docker compose logs nginx
docker compose logs db

# Suivre les logs en temps réel
docker compose logs -f node-app
```

### Exécuter une commande dans un conteneur
```bash
# Tester la connexion à la BDD depuis le conteneur Node
docker compose exec node-app curl -s http://localhost:3000/api/health
```

### Arrêter la stack proprement
```bash
docker compose down
```

### Arrêter et supprimer les volumes (attention : supprime les données MySQL)
```bash
docker compose down -v
```

---

## 5. Vérifications & validation

| Vérification | Commande | Résultat attendu |
|---|---|---|
| Conteneurs actifs | `docker compose ps` | 3 services en `running` |
| Connexion Node ↔ MySQL | `docker compose exec node-app curl -s http://localhost:3000/api/health` | `{"status":"ok","database":"connected"}` |
| Reverse proxy HTTPS | `curl -k https://formation.local/api/health` | Réponse de l'API |
| Certificat SSL | `openssl s_client -connect formation.local:443 -showcerts` | Certificat affiché |
| Cron opérationnel | `sudo crontab -l` | Ligne de tâche présente |
| Logs de renouvellement | `cat /var/log/certbot-renew.log` | Historique des exécutions |

---

## 6. Automatisation — Script de renouvellement

### Rendre le script exécutable
```bash
sudo chmod +x /chemin/vers/scripts/renew-cert.sh
```

### Configurer la tâche cron
```bash
# Ouvrir l'éditeur de crontab
sudo crontab -e
```

Ajouter la ligne suivante (exécution à 3h du matin, tous les 3 mois) :
```
0 3 1 */3 * /chemin/vers/scripts/renew-cert.sh
```

### Exporter la crontab (livrable)
```bash
sudo crontab -l > crontab_export.txt
```

---

## 7. Réseau & communication entre services

Les services communiquent entre eux par **nom de service** (DNS Docker interne), pas par `localhost` :

| Service | Adresse interne | Port |
|---|---|---|
| Node.js | `node-app` | `3000` |
| MySQL | `db` | `3306` |
| NGINX | `nginx` | `80` / `443` |

Seuls les ports **80** et **443** sont exposés sur l'hôte (via NGINX). La base de données n'est pas accessible depuis l'extérieur.

---

## 8. Logs & emplacements importants

| Élément | Emplacement |
|---|---|
| Certificats SSL | `/etc/letsencrypt/live/formation.local/` (hôte) |
| Logs de renouvellement | `/var/log/certbot-renew.log` (hôte) |
| Logs NGINX | Volume Docker `nginx_logs` |
| Logs applicatifs Node.js | Volume Docker `app_logs` |
| Données MySQL | Volume Docker `mysql_data` |

---

## 9. Différences dev / prod

| | Développement | Production |
|---|---|---|
| Variables d'environnement | `NODE_ENV=development` | `NODE_ENV=production` |
| Volumes Node.js | Code source monté en live | Image immuable (rebuild requis) |
| Logs | Console + fichier | Fichier uniquement |
| Certificat | Auto-signé (OpenSSL) | Let's Encrypt (Certbot) |
| Rebuild | Fréquent | Sur déploiement uniquement |

---

## 10. Nettoyage complet (attention : irréversible)

```bash
# Arrêter et supprimer conteneurs, réseaux et volumes
docker compose down -v

# Supprimer les images buildées
docker rmi formalis_node

# Supprimer tous les volumes Docker non utilisés
docker volume prune
```

> **Attention** : `docker compose down -v` supprime les données MySQL. À n'utiliser qu'en développement ou pour repartir de zéro.
