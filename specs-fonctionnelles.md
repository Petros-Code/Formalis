# Spécifications fonctionnelles — Formalis

## Acteurs du système

| Acteur | Description |
|---|---|
| **Apprenant** | Utilisateur inscrit à un ou plusieurs cours |
| **Formateur** | Crée et gère les cours, évalue les travaux |
| **Administrateur** | Gère la plateforme, les utilisateurs et les accès |

---

## 1. Gestion des utilisateurs

### 1.1 Inscription
- **Acteur** : Apprenant
- **Description** : Un visiteur peut créer un compte en renseignant son nom, son email et un mot de passe.
- **Résultat attendu** : Un compte est créé avec le rôle `apprenant`. Un email de confirmation est envoyé.

### 1.2 Connexion / Déconnexion
- **Acteur** : Apprenant, Formateur, Administrateur
- **Description** : L'utilisateur se connecte avec son email et son mot de passe. Une session est ouverte.
- **Résultat attendu** : L'utilisateur est redirigé vers son tableau de bord. La session est sécurisée.

### 1.3 Gestion des comptes utilisateurs
- **Acteur** : Administrateur
- **Description** : L'administrateur peut créer, modifier, désactiver ou supprimer un compte utilisateur, et modifier son rôle.
- **Résultat attendu** : Les modifications sont appliquées immédiatement. L'utilisateur concerné est notifié.

---

## 2. Gestion des cours

### 2.1 Création d'un cours
- **Acteur** : Formateur
- **Description** : Le formateur crée un cours en renseignant un titre, une description, un niveau, un prix et une catégorie. Il peut y ajouter des chapitres et des ressources.
- **Résultat attendu** : Le cours est enregistré en statut `brouillon` et visible uniquement du formateur jusqu'à sa publication.

### 2.2 Publication d'un cours
- **Acteur** : Formateur, Administrateur
- **Description** : Le formateur soumet le cours pour publication. L'administrateur peut valider ou refuser.
- **Résultat attendu** : Le cours passe en statut `publié` et devient visible pour les apprenants.

### 2.3 Consultation d'un cours
- **Acteur** : Apprenant
- **Description** : L'apprenant inscrit peut consulter les chapitres et les ressources d'un cours.
- **Résultat attendu** : Le contenu est affiché, la progression est mise à jour automatiquement.

### 2.4 Gestion des chapitres
- **Acteur** : Formateur
- **Description** : Le formateur peut ajouter, modifier, réordonner ou supprimer des chapitres dans un cours.
- **Résultat attendu** : Les chapitres sont mis à jour et l'ordre est respecté côté apprenant.

---

## 3. Inscription aux cours

### 3.1 Inscription à un cours
- **Acteur** : Apprenant
- **Description** : L'apprenant peut s'inscrire à un cours (gratuit ou après paiement). L'inscription est enregistrée avec la date et l'état `actif`.
- **Résultat attendu** : L'apprenant accède au contenu du cours. Une confirmation est affichée.

### 3.2 Suivi de la progression
- **Acteur** : Apprenant
- **Description** : La plateforme enregistre automatiquement la progression de l'apprenant chapitre par chapitre.
- **Résultat attendu** : Un pourcentage de complétion est affiché sur le tableau de bord.

---

## 4. Téléversement de ressources et de devoirs

### 4.1 Dépôt d'un devoir
- **Acteur** : Apprenant
- **Description** : L'apprenant peut déposer un fichier (devoir) dans le cadre d'un cours.
- **Résultat attendu** : Le fichier est enregistré et visible par le formateur concerné.

### 4.2 Ajout de ressources pédagogiques
- **Acteur** : Formateur
- **Description** : Le formateur peut téléverser des ressources (PDF, vidéos, liens) liées à un chapitre.
- **Résultat attendu** : Les ressources sont accessibles aux apprenants inscrits.

---

## 5. Évaluations et notation

### 5.1 Notation d'un devoir
- **Acteur** : Formateur
- **Description** : Le formateur consulte les devoirs rendus et attribue une note et un commentaire.
- **Résultat attendu** : La note est enregistrée et visible par l'apprenant dans son tableau de bord.

### 5.2 Avis sur une formation
- **Acteur** : Apprenant
- **Description** : À la fin d'une formation, l'apprenant peut laisser une note (1 à 5) et un commentaire sur le cours.
- **Résultat attendu** : L'avis est publié sur la page du cours et visible par tous.

---

## 6. Forum et questions

### 6.1 Poser une question
- **Acteur** : Apprenant
- **Description** : L'apprenant peut poser une question liée à un cours dans le forum associé.
- **Résultat attendu** : La question est publiée et visible par les autres apprenants et le formateur.

### 6.2 Répondre à une question
- **Acteur** : Formateur, Apprenant
- **Description** : Le formateur ou un autre apprenant peut répondre à une question du forum.
- **Résultat attendu** : La réponse est associée à la question et notifie l'auteur.

---

## 7. Tableau de bord et statistiques

### 7.1 Tableau de bord apprenant
- **Acteur** : Apprenant
- **Description** : L'apprenant visualise ses cours en cours, sa progression, ses notes et son activité récente.
- **Résultat attendu** : Un tableau de bord personnalisé est affiché avec des indicateurs clairs.

### 7.2 Tableau de bord formateur
- **Acteur** : Formateur
- **Description** : Le formateur visualise ses cours publiés, le nombre d'inscrits, les devoirs en attente et les avis reçus.
- **Résultat attendu** : Un tableau de bord synthétique est affiché.

---

## 8. Paiements

### 8.1 Achat d'un cours
- **Acteur** : Apprenant
- **Description** : L'apprenant peut acheter un cours payant via un moyen de paiement. Une facture est générée.
- **Résultat attendu** : Le paiement est enregistré avec son statut (`en attente`, `validé`, `échoué`). L'accès au cours est débloqué si validé.

---

## 9. Gestion des sessions et des accès

### 9.1 Contrôle des accès
- **Acteur** : Administrateur
- **Description** : L'administrateur peut restreindre l'accès à un cours ou suspendre un utilisateur.
- **Résultat attendu** : L'utilisateur concerné ne peut plus accéder aux ressources restreintes.

### 9.2 Journalisation des activités
- **Acteur** : Système
- **Description** : La plateforme enregistre automatiquement les événements clés (connexion, consultation de cours, progression, dépôt de devoir).
- **Résultat attendu** : Les logs sont consultables par l'administrateur pour audit ou débogage.
