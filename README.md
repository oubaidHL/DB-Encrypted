---

# 🛡️ Secure SQLite3 with RSA Encryption (Docker)

Ce projet démontre comment sécuriser des données sensibles (comme des numéros de carte bancaire) dans une base de données SQLite3 en utilisant le chiffrement asymétrique **RSA** via **OpenSSL/Cryptography**.

## 📌 Le Problème : La vulnérabilité de SQLite

Par défaut, SQLite stocke les données en clair. Si un attaquant parvient à voler le fichier `.db` (en accédant au serveur ou à une sauvegarde), il peut lire toutes les informations en utilisant un simple éditeur de texte ou un navigateur SQLite.

## 🚀 La Solution : Chiffrement Asymétrique (RSA)

Pour protéger les données, ce projet utilise deux conteneurs Docker pour illustrer la différence entre une base de données vulnérable et une base de données sécurisée.

### Pourquoi RSA ?

Contrairement au chiffrement par mot de passe (symétrique), RSA utilise une paire de clés :

* **Clé Publique (`public_key.pem`)** : Utilisée par l'application pour **verrouiller** (chiffrer) les données. Même si cette clé est volée, elle ne peut pas servir à lire les données.
* **Clé Privée (`private_key.pem`)** : Restée en lieu sûr, elle est la seule capable de **déverrouiller** (déchiffrer) les données.

---

## 📂 Structure du Projet

* `data/` : Contient la base de données standard (non sécurisée).
* `data2/` : Contient la base de données sécurisée et les clés RSA.
* `encrypt_db.py` : Script Python qui génère les clés et insère les données sous forme de **BLOB** (Binary Large Object).
* `docker-compose.yml` : Orchestration des services.

---

## 🛠️ Installation et Utilisation

### 1. Lancer l'environnement

```bash
docker-compose up -d

```

### 2. Simuler une attaque (Lecture du fichier `.db`)

Si vous essayez de lire le contenu sans la clé privée :

```bash
docker exec -it sqlite_encrypted sqlite3 /root/db/clients.db "SELECT * FROM secure_clients;"

```

**Résultat :** Le champ `encrypted_card` affichera des données binaires illisibles (BLOB), rendant l'attaque inutile.

### 3. Déchiffrement Légitime

Pour voir les données réelles, seul le détenteur de la clé privée peut exécuter le script de déchiffrement (non inclus par défaut dans le container de production pour plus de sécurité).

---

## 📊 Comparaison Technique

| Caractéristique | SQLite Standard | SQLite + RSA (Ce projet) |
| --- | --- | --- |
| **Format des données** | Texte clair (Plain Text) | Binaire (BLOB) |
| **Visibilité sur Windows** | Lisible via Bloc-notes | Illisible / Chiffré |
| **Sécurité du fichier** | Nulle si le fichier est volé | Haute (Nécessite la clé privée) |
| **Type de stockage** | `TEXT` | `BLOB` |

---

## ⚠️ Sécurité (Best Practices)

Dans un environnement de production réel :

1. **Ne jamais uploader** le fichier `private_key.pem` sur GitHub (ajoutez-le au `.gitignore`).
2. Utiliser des **Docker Secrets** ou un gestionnaire de clés (HashiCorp Vault) pour stocker la clé privée.

---
