# Compte Rendu de TD5 : Mise en place de Pipelines CI/CD avec GitHub Actions et AWS

**Auteurs :** Florian KENZOUA & Daryl CODDEVILLE. 
**Module :** E4FD - DevOps
**Sujet :** Intégration et Déploiement Continus (CI/CD), Sécurité OIDC et Infrastructure as Code  
**Date :** Décembre 2025

---

## 1. Introduction

Ce travail pratique avait pour objectif de passer d'une gestion manuelle de l'infrastructure à une automatisation complète via des pipelines CI/CD. Nous avons mis en œuvre les pratiques modernes du DevOps : tests automatisés à chaque commit, sécurisation des accès cloud sans clés statiques (OIDC), et déploiement continu de l'infrastructure via OpenTofu (Terraform).

L'enjeu principal était de garantir que tout code fusionné sur la branche principale (`main`) soit testé, validé et déployé automatiquement.

## 2. Objectifs Pédagogiques

Les compétences techniques validées durant ce laboratoire sont :
* **Intégration Continue (CI) :** Exécution automatique de tests applicatifs et d'infrastructure.
* **Sécurité Cloud (OIDC) :** Authentification sécurisée entre GitHub et AWS sans gestion de clés d'accès longue durée.
* **Gestion d'État Distant :** Stockage sécurisé et partagé de l'état Terraform (S3 + DynamoDB).
* **Déploiement Continu (CD) :** Automatisation des commandes `tofu plan` sur les Pull Requests et `tofu apply` lors de la fusion.

## 3. Architecture et Réalisations Techniques

### 3.1. Intégration Continue (CI) et Tests
Nous avons configuré des workflows GitHub Actions pour valider la qualité du code avant toute intégration :
* **Tests Applicatifs :** Un workflow déclenche l'installation des dépendances (`npm install`) et les tests unitaires (`npm test`) d'une application Node.js exemple à chaque push.
* **Tests d'Infrastructure :** Un second workflow valide le code OpenTofu en exécutant `tofu init` et `tofu test`, garantissant que les modifications d'infrastructure ne comportent pas d'erreurs de syntaxe ou de logique.

### 3.2. Authentification Sécurisée (OIDC)
Pour éviter de stocker des `AWS_ACCESS_KEY_ID` et `AWS_SECRET_ACCESS_KEY` dans les secrets GitHub (pratique risquée), nous avons mis en place **OpenID Connect (OIDC)**.
* **Principe :** GitHub agit comme un fournisseur d'identité de confiance pour AWS.
* **Implémentation :** Création d'un "Identity Provider" dans IAM et définition de rôles spécifiques (`PlanRole`, `ApplyRole`) que GitHub Actions peut assumer temporairement pour effectuer les déploiements.

### 3.3. Gestion de l'État Distant (Remote Backend)
Afin de permettre la collaboration, l'état de l'infrastructure (`terraform.tfstate`) a été migré du disque local vers le Cloud :
* **Stockage S3 :** Le fichier d'état est stocké dans un bucket S3 chiffré et versionné.
* **Verrouillage DynamoDB :** Une table DynamoDB gère les verrous (`locks`) pour empêcher deux pipelines de modifier l'infrastructure simultanément.

### 3.4. Pipeline de Déploiement (CD)
Nous avons automatisé le cycle de vie de l'infrastructure via deux workflows distincts :
1.  **Sur Pull Request (`tofu plan`) :** Génère un plan d'exécution spéculatif et le poste automatiquement en commentaire de la PR. Cela permet la revue de code et la validation des impacts avant fusion.
2.  **Sur Merge vers Main (`tofu apply`) :** Applique concrètement les changements sur AWS une fois le code validé.

## 4. Difficultés Rencontrées et Solutions

Outre la complexité de la configuration IAM, nous avons rencontré une difficulté majeure liée à la gestion de versions Git.

**La Gestion du `.gitignore` et des Fichiers Temporaires**

* **Problème :** Lors de l'exécution locale des commandes OpenTofu/Terraform, de nombreux fichiers sont générés : le dossier `.terraform` (contenant les binaires des providers), le fichier de sauvegarde `.tfstate` (contenant des informations sensibles en clair) et les fichiers de verrouillage.
* **Risque :** Pousser ces fichiers sur le dépôt Git aurait deux conséquences graves :
    1.  **Sécurité :** Exposition potentielle de secrets ou d'informations sur l'infrastructure.
    2.  **Conflits :** Impossibilité pour le binôme de travailler, car l'état local de l'un écraserait celui de l'autre, rendant le Remote Backend inutile.
* **Solution :** Nous avons dû configurer rigoureusement le fichier `.gitignore` à la racine du projet pour exclure systématiquement :
    * `**/.terraform/`
    * `*.tfstate`
    * `*.tfstate.backup`
    * `.tfvars` (fichiers de variables contenant des secrets)
    
    Cette rigueur a été indispensable pour garantir un pipeline CI/CD sain, où seul le code source est versionné, et non les artéfacts de déploiement.

## 5. Conclusion

Ce TD5 a permis de structurer notre approche DevOps. En remplaçant les déploiements manuels par des pipelines automatisés et sécurisés, nous avons posé les bases nécessaires à la réalisation du projet final, garantissant une livraison fiable et auditable de l'infrastructure.
