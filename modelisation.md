# Modélisation de la base de données — Formalis

---

## MCD — Modèle Conceptuel de Données (Merise)

### Entités

```
UTILISATEUR
───────────────────────────
# id
  nom
  email
  mot_de_passe
  role (apprenant | formateur | administrateur)
  created_at

COURS
───────────────────────────
# id
  titre
  description
  niveau (débutant | intermédiaire | avancé)
  prix
  statut (brouillon | publié | archivé)
  date_publication

CHAPITRE
───────────────────────────
# id
  titre
  contenu
  ordre

RESSOURCE
───────────────────────────
# id
  nom
  type (pdf | video | lien)
  url

DEVOIR
───────────────────────────
# id
  titre
  consigne
  date_limite

SOUMISSION
───────────────────────────
# id
  fichier
  date_soumission
  note
  commentaire_correcteur

INSCRIPTION
───────────────────────────
# id
  date_inscription
  etat (actif | terminé | annulé)
  progression (%)

AVIS
───────────────────────────
# id
  note (1 à 5)
  commentaire
  date

PAIEMENT
───────────────────────────
# id
  montant
  moyen_paiement (carte | virement | paypal)
  statut (en_attente | validé | échoué)
  date
  numero_facture

CATEGORIE
───────────────────────────
# id
  nom
  description

TAG
───────────────────────────
# id
  nom

QUESTION
───────────────────────────
# id
  titre
  contenu
  date

REPONSE
───────────────────────────
# id
  contenu
  date

LOG_ACTIVITE
───────────────────────────
# id
  type_action (connexion | consultation | progression | soumission)
  date
  detail
```

---

### Associations et cardinalités

```
UTILISATEUR ──(1,n)── CREE ──(0,1)── COURS
  (un formateur crée plusieurs cours ; un cours a un seul formateur)

COURS ──(n,1)── APPARTIENT_A ──(1,n)── CATEGORIE
  (un cours appartient à une catégorie ; une catégorie regroupe plusieurs cours)

COURS ──(1,n)── CONTIENT ──(n,1)── CHAPITRE
  (un cours contient plusieurs chapitres ; un chapitre appartient à un cours)

CHAPITRE ──(1,n)── POSSEDE ──(n,1)── RESSOURCE
  (un chapitre possède plusieurs ressources)

CHAPITRE ──(1,n)── PROPOSE ──(n,1)── DEVOIR
  (un chapitre peut proposer plusieurs devoirs)

UTILISATEUR ──(1,n)── SOUMET ──(n,1)── SOUMISSION ──(n,1)── DEVOIR
  (un apprenant soumet une réponse par devoir)

UTILISATEUR ──(n,m)── S_INSCRIT ──(n,m)── COURS
  → Association : INSCRIPTION
  (un apprenant s'inscrit à plusieurs cours ; un cours a plusieurs inscrits)

UTILISATEUR ──(n,m)── REDIGE ──(n,m)── COURS
  → Association : AVIS
  (un apprenant laisse un avis par cours suivi)

UTILISATEUR ──(n,m)── EFFECTUE ──(n,m)── COURS
  → Association : PAIEMENT
  (un apprenant peut payer plusieurs cours)

COURS ──(n,m)── EST_TAGUE ──(n,m)── TAG
  → Association : COURS_TAG

COURS ──(1,n)── A_POUR_FORUM ──(n,1)── QUESTION
  (un cours possède plusieurs questions de forum)

QUESTION ──(1,n)── A_POUR_REPONSE ──(n,1)── REPONSE
  (une question peut avoir plusieurs réponses)

UTILISATEUR ──(1,n)── POSE ──(n,1)── QUESTION
  (un utilisateur pose plusieurs questions)

UTILISATEUR ──(1,n)── REPOND ──(n,1)── REPONSE
  (un utilisateur rédige plusieurs réponses)

UTILISATEUR ──(1,n)── GENERE ──(n,1)── LOG_ACTIVITE
  (chaque action d'un utilisateur génère un log)
```

---

## MLD — Modèle Logique de Données (3FN)

### Tables

```sql
utilisateurs (
  id              INT PRIMARY KEY AUTO_INCREMENT,
  nom             VARCHAR(100) NOT NULL,
  email           VARCHAR(150) NOT NULL UNIQUE,
  mot_de_passe    VARCHAR(255) NOT NULL,
  role            ENUM('apprenant', 'formateur', 'administrateur') NOT NULL DEFAULT 'apprenant',
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

categories (
  id              INT PRIMARY KEY AUTO_INCREMENT,
  nom             VARCHAR(100) NOT NULL UNIQUE,
  description     TEXT
)

tags (
  id              INT PRIMARY KEY AUTO_INCREMENT,
  nom             VARCHAR(50) NOT NULL UNIQUE
)

cours (
  id              INT PRIMARY KEY AUTO_INCREMENT,
  titre           VARCHAR(200) NOT NULL,
  description     TEXT,
  niveau          ENUM('débutant', 'intermédiaire', 'avancé') NOT NULL,
  prix            DECIMAL(8,2) NOT NULL DEFAULT 0.00,
  statut          ENUM('brouillon', 'publié', 'archivé') NOT NULL DEFAULT 'brouillon',
  date_publication DATE,
  id_formateur    INT NOT NULL,
  id_categorie    INT NOT NULL,
  FOREIGN KEY (id_formateur) REFERENCES utilisateurs(id),
  FOREIGN KEY (id_categorie) REFERENCES categories(id)
)

cours_tags (
  id_cours        INT NOT NULL,
  id_tag          INT NOT NULL,
  PRIMARY KEY (id_cours, id_tag),
  FOREIGN KEY (id_cours) REFERENCES cours(id) ON DELETE CASCADE,
  FOREIGN KEY (id_tag)   REFERENCES tags(id)  ON DELETE CASCADE
)

chapitres (
  id              INT PRIMARY KEY AUTO_INCREMENT,
  titre           VARCHAR(200) NOT NULL,
  contenu         TEXT,
  ordre           INT NOT NULL DEFAULT 1,
  id_cours        INT NOT NULL,
  FOREIGN KEY (id_cours) REFERENCES cours(id) ON DELETE CASCADE
)

ressources (
  id              INT PRIMARY KEY AUTO_INCREMENT,
  nom             VARCHAR(200) NOT NULL,
  type            ENUM('pdf', 'video', 'lien') NOT NULL,
  url             VARCHAR(500) NOT NULL,
  id_chapitre     INT NOT NULL,
  FOREIGN KEY (id_chapitre) REFERENCES chapitres(id) ON DELETE CASCADE
)

devoirs (
  id              INT PRIMARY KEY AUTO_INCREMENT,
  titre           VARCHAR(200) NOT NULL,
  consigne        TEXT,
  date_limite     DATETIME,
  id_chapitre     INT NOT NULL,
  FOREIGN KEY (id_chapitre) REFERENCES chapitres(id) ON DELETE CASCADE
)

soumissions (
  id                    INT PRIMARY KEY AUTO_INCREMENT,
  fichier               VARCHAR(500) NOT NULL,
  date_soumission       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  note                  DECIMAL(4,2),
  commentaire_correcteur TEXT,
  id_apprenant          INT NOT NULL,
  id_devoir             INT NOT NULL,
  UNIQUE (id_apprenant, id_devoir),
  FOREIGN KEY (id_apprenant) REFERENCES utilisateurs(id),
  FOREIGN KEY (id_devoir)    REFERENCES devoirs(id)
)

inscriptions (
  id                INT PRIMARY KEY AUTO_INCREMENT,
  date_inscription  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  etat              ENUM('actif', 'terminé', 'annulé') NOT NULL DEFAULT 'actif',
  progression       TINYINT UNSIGNED NOT NULL DEFAULT 0,
  id_apprenant      INT NOT NULL,
  id_cours          INT NOT NULL,
  UNIQUE (id_apprenant, id_cours),
  FOREIGN KEY (id_apprenant) REFERENCES utilisateurs(id),
  FOREIGN KEY (id_cours)     REFERENCES cours(id)
)

avis (
  id              INT PRIMARY KEY AUTO_INCREMENT,
  note            TINYINT NOT NULL CHECK (note BETWEEN 1 AND 5),
  commentaire     TEXT,
  date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  id_apprenant    INT NOT NULL,
  id_cours        INT NOT NULL,
  UNIQUE (id_apprenant, id_cours),
  FOREIGN KEY (id_apprenant) REFERENCES utilisateurs(id),
  FOREIGN KEY (id_cours)     REFERENCES cours(id)
)

paiements (
  id                INT PRIMARY KEY AUTO_INCREMENT,
  montant           DECIMAL(8,2) NOT NULL,
  moyen_paiement    ENUM('carte', 'virement', 'paypal') NOT NULL,
  statut            ENUM('en_attente', 'validé', 'échoué') NOT NULL DEFAULT 'en_attente',
  date              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  numero_facture    VARCHAR(50) NOT NULL UNIQUE,
  id_apprenant      INT NOT NULL,
  id_cours          INT NOT NULL,
  FOREIGN KEY (id_apprenant) REFERENCES utilisateurs(id),
  FOREIGN KEY (id_cours)     REFERENCES cours(id)
)

questions (
  id              INT PRIMARY KEY AUTO_INCREMENT,
  titre           VARCHAR(200) NOT NULL,
  contenu         TEXT NOT NULL,
  date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  id_auteur       INT NOT NULL,
  id_cours        INT NOT NULL,
  FOREIGN KEY (id_auteur) REFERENCES utilisateurs(id),
  FOREIGN KEY (id_cours)  REFERENCES cours(id) ON DELETE CASCADE
)

reponses (
  id              INT PRIMARY KEY AUTO_INCREMENT,
  contenu         TEXT NOT NULL,
  date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  id_auteur       INT NOT NULL,
  id_question     INT NOT NULL,
  FOREIGN KEY (id_auteur)   REFERENCES utilisateurs(id),
  FOREIGN KEY (id_question) REFERENCES questions(id) ON DELETE CASCADE
)

logs_activite (
  id              INT PRIMARY KEY AUTO_INCREMENT,
  type_action     ENUM('connexion', 'consultation', 'progression', 'soumission') NOT NULL,
  date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  detail          VARCHAR(255),
  id_utilisateur  INT NOT NULL,
  id_cours        INT,
  FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs(id),
  FOREIGN KEY (id_cours)       REFERENCES cours(id) ON DELETE SET NULL
)
```

---

### Contraintes d'intégrité notables

| Contrainte | Table | Détail |
|---|---|---|
| Un apprenant ne peut s'inscrire qu'une fois par cours | `inscriptions` | `UNIQUE (id_apprenant, id_cours)` |
| Un apprenant ne peut laisser qu'un avis par cours | `avis` | `UNIQUE (id_apprenant, id_cours)` |
| Un apprenant ne peut soumettre qu'une fois par devoir | `soumissions` | `UNIQUE (id_apprenant, id_devoir)` |
| La note d'un avis est entre 1 et 5 | `avis` | `CHECK (note BETWEEN 1 AND 5)` |
| Le numéro de facture est unique | `paiements` | `UNIQUE (numero_facture)` |
| La suppression d'un cours supprime ses chapitres | `chapitres` | `ON DELETE CASCADE` |
| La suppression d'un chapitre supprime ses ressources et devoirs | `ressources`, `devoirs` | `ON DELETE CASCADE` |
| La suppression d'un cours ne supprime pas les logs | `logs_activite` | `ON DELETE SET NULL` |
