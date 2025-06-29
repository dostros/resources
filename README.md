# PipouRP

**PipouRP** est un projet de serveur FiveM basé sur QBCore, conçu pour offrir une expérience de jeu immersive avec des systèmes personnalisés et des interfaces modernes.

## ✨ Fonctionnalités principales

- 🪓 **Métier bûcheron** : récolte, transformation et vente du bois
- 🚗 **Garage personnalisé** : menu NUI interactif, gestion de spawn/déspawn
- 🔐 **Système de verrouillage** : gestion des portes sécurisées avec interface et stream d’icônes
- 📱 **Tablette de police (MDT)** : accès aux données via une interface moderne en HTML/CSS avec Tailwind

## 🧰 Pré-requis

- [QBCore Framework](https://github.com/qbcore-framework)
- Serveur FiveM compatible
- Ressources de base comme `qb-core`, `qb-target`, etc. selon les scripts

## 📦 Installation

1. Télécharger ou cloner ce dépôt dans le dossier `resources/` de votre serveur.
2. Renommer le dossier si besoin (éviter les espaces ou caractères spéciaux).
3. Ajouter les lignes suivantes à votre `server.cfg` :

```cfg
ensure d-bucheron
ensure d-garage
ensure d-locksystem
ensure d-MDT
```

> 🔁 L'ordre peut varier selon vos dépendances. Vérifiez que `qb-core` est démarré avant ces scripts.

## 🧑‍💻 Auteurs et crédits

- Développement : **Dostros**
- Design interface : Intégration NUI/Tailwind
- Framework : Basé sur QBCore

## 📄 Licence

Ce projet est distribué **sans licence explicite**. Merci de ne pas redistribuer sans autorisation. Pour toute question, contactez le développeur principal.

---

Merci d’utiliser **PipouRP** ! 🚀
