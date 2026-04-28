# Spécifications techniques — Formalis

---

## 1. Technologies utilisées

| Composant | Technologie | Version |
|---|---|---|
| API backend | Node.js + Express | Node 20 (LTS) |
| Base de données | MySQL | 8.0 |
| Reverse proxy | NGINX | Alpine (dernière stable) |
| Conteneurisation | Docker + Docker Compose | Compose v2 |
| Certificat SSL | Certbot / OpenSSL | — |
| Système hôte | Linux (Debian/Ubuntu) | — |

---

## 2. Architecture logicielle et réseau

```
                        Internet
                           │
                        Port 443 (HTTPS)
                        Port 80  (HTTP → redirect HTTPS)
                           │
                    ┌──────▼──────┐
                    │    NGINX    │  (conteneur)
                    │  formalis_  │
                    │   nginx     │
                    └──────┬──────┘
                           │ /api/ → proxy_pass
                    ┌──────▼──────┐
                    │  Node.js   │  (conteneur)
                    │  formalis_ │
                    │   node     │
                    └──────┬──────┘
                           │ mysql2
                    ┌──────▼──────┐
                    │   MySQL    │  (conteneur)
                    │  formalis_ │
                    │    db      │
                    └─────────────┘

        Tous les conteneurs communiquent via :
        réseau Docker interne → formalis_network
```

- NGINX est le **seul point d'entrée** exposé sur l'hôte
- Node.js et MySQL ne sont **pas accessibles depuis l'extérieur**
- Les services se joignent par **nom de service** (DNS Docker interne)

---

## 3. Ports exposés

| Service | Port interne | Port hôte exposé | Accessible depuis l'extérieur |
|---|---|---|---|
| NGINX | 80, 443 | 80, 443 | Oui |
| Node.js | 3000 | — | Non (via NGINX uniquement) |
| MySQL | 3306 | — | Non |

---

## 4. Variables d'environnement

Stockées dans le fichier `.env` à la racine du projet (non commité). Le fichier `.env.example` sert de référence.

| Variable | Description | Exemple |
|---|---|---|
| `NODE_ENV` | Environnement applicatif | `production` |
| `PORT` | Port d'écoute de l'API Node.js | `3000` |
| `MYSQL_HOST` | Nom du service MySQL (DNS Docker) | `db` |
| `MYSQL_DATABASE` | Nom de la base de données | `formalis_db` |
| `MYSQL_USER` | Utilisateur MySQL | `formalis_user` |
| `MYSQL_PASSWORD` | Mot de passe utilisateur MySQL | `***` |
| `MYSQL_ROOT_PASSWORD` | Mot de passe root MySQL | `***` |

---

## 5. Volumes Docker

| Volume | Contenu | Type |
|---|---|---|
| `mysql_data` | Données MySQL persistantes | Volume nommé Docker |
| `app_logs` | Logs applicatifs Node.js | Volume nommé Docker |
| `nginx_logs` | Logs NGINX | Volume nommé Docker |
| `/etc/letsencrypt` (hôte) | Certificats SSL | Montage depuis l'hôte (read-only) |

---

## 6. Certificats SSL

- **Emplacement sur l'hôte** : `/etc/letsencrypt/live/formation.local/`
- **Fichiers utilisés par NGINX** :
  - `fullchain.pem` — certificat public
  - `privkey.pem` — clé privée
- Les certificats sont montés en **lecture seule** dans le conteneur NGINX
- Ils ne sont **jamais copiés** dans le projet Git

---

## 7. Logs et emplacements

| Élément | Emplacement |
|---|---|
| Logs NGINX | Volume Docker `nginx_logs` → `/var/log/nginx/` |
| Logs Node.js | Volume Docker `app_logs` → `/app/logs/` |
| Logs MySQL | Via `docker compose logs db` |
| Logs renouvellement SSL | `/var/log/certbot-renew.log` (hôte) |

### Consulter les logs

```bash
# Logs d'un service en temps réel
docker compose logs -f node-app
docker compose logs -f nginx
docker compose logs -f db

# Logs de renouvellement SSL
cat /var/log/certbot-renew.log
```

---

## 8. Healthchecks

| Service | Mécanisme | Intervalle | Tentatives |
|---|---|---|---|
| Node.js | `curl http://localhost:3000/api/health` | 30s | 3 |
| MySQL | `mysqladmin ping` | 30s | 5 |

Node.js démarre **uniquement après** que MySQL soit `healthy` (via `depends_on: condition: service_healthy`).

---

## 9. Initialisation de la base de données

Le fichier `mysql/init.sql` est automatiquement exécuté par MySQL au **premier démarrage** du conteneur (via `/docker-entrypoint-initdb.d/`).

Il crée :
- La base `formalis_db`
- La table `users` avec les rôles
- Des données de test

> Ce script n'est **pas rejoué** si le volume `mysql_data` existe déjà.

---

## 10. Différences dev / prod

| | Développement | Production |
|---|---|---|
| `NODE_ENV` | `development` | `production` |
| Certificat SSL | Auto-signé (OpenSSL local) | Let's Encrypt (Certbot) |
| Volumes Node.js | Code monté en live (hot reload) | Image immuable |
| Logs | Console + fichier | Fichier uniquement |
| Rebuild | Fréquent (`--build`) | Sur déploiement uniquement |
| Base de données | Données de test | Données réelles |

---

## 11. Commandes de nettoyage

```bash
# Arrêter proprement
docker compose down

# Arrêter et supprimer les volumes (données perdues)
docker compose down -v

# Supprimer les images buildées
docker rmi formalis_node

# Nettoyer les volumes orphelins
docker volume prune
```

> **Attention** : `docker compose down -v` supprime définitivement les données MySQL.
