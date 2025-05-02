# PipouUI

**PipouUI** est un système d'interface utilisateur NUI complet pour FiveM. Il permet de créer des menus dynamiques, des barres de progression, des notifications stylisées, et offre une navigation fluide au clavier comme à la souris.

---

## ✨ Fonctionnalités principales

- ✅ Menus dynamiques :
  - Boutons simples
  - Checkbox
  - Sliders numériques
  - Sections non interactives
  - Menus à onglets
- 🔁 Système de navigation avec pile (retour arrière, historique)
- 🔄 Menus temporaires avec expiration (`TTL`)
- 🎯 Positionnement personnalisable : coin haut/bas gauche/droit, centre
- 🎮 Navigation clavier (flèches + Entrée/Escape)
- 🖱️ Support souris (clics, molette)
- 🔔 Notifications intégrées (succès, erreur, info, alertes)
- ⏳ Progressbar avec ou sans annulation (`X`)
- ⚙️ API Lua simple à intégrer
- 📐 Responsive (1080p à 4K pris en charge)
- ⚡ Performances optimales : 0 boucle côté client, full event-based

---

## 📦 Installation

1. Déplace le dossier `pipouui` dans `resources/` de ton serveur.
2. Dans `server.cfg` ajoute :

```cfg
ensure pipouui
```

3. Tu peux désormais utiliser toutes les fonctions via :

```lua
exports['PipouUI']:NomDeLaFonction(...)
```

---

## 🧩 API LUA : Détails complets

### 🎛️ Créer un menu personnalisé

```lua
local id = exports['PipouUI']:CreateMenu("Garage", "Choisissez un véhicule", nil, "menu-bottom-right")

exports['PipouUI']:AddButton(id, "Sultan RS", function()
    print("Sultan sélectionnée")
end)

exports['PipouUI']:OpenMenu(id)
```

### 🎯 OpenSimpleMenu (version rapide)

```lua
exports['PipouUI']:OpenSimpleMenu("Actions rapides", "Sélectionnez une option", {
    {
        type = "button",
        label = "Faire une action",
        action = function()
            print("Action exécutée")
        end
    },
    {
        type = "slider",
        label = "Volume",
        data = { value = 5, min = 0, max = 10, step = 1 },
        action = function(val)
            print("Volume :", val)
        end
    },
    {
        type = "checkbox",
        label = "Activer le mode",
        data = { checked = true },
        action = function() print("Toggled") end
    }
}, "menu-center")
```

### 📥 Input utilisateur

```lua
exports['PipouUI']:OpenInputMenu("Entrez un nom", "Nom du véhicule", function(text)
    print("Vous avez saisi :", text)
end)
```

### 📋 Liste simple

```lua
exports['PipouUI']:OpenListMenu("Choix disponibles", "Sélectionnez :", {
    "Choix A", "Choix B", "Choix C"
}, function(index)
    print("Vous avez choisi l'option n°", index)
end)
```

### 🗂️ Onglets multiples

```lua
exports['PipouUI']:OpenTabbedMenu("Menu Avancé", "Choisissez une catégorie", {
    {
        label = "Général",
        options = {
            { label = "Option 1", action = function() print("Option 1") end }
        }
    },
    {
        label = "Audio",
        options = {
            { type = "slider", label = "Volume", data = { value = 2, min = 0, max = 10 }, action = function(v) print("Volume:", v) end }
        }
    }
})
```

---

## 🔔 Notifications

```lua
exports['PipouUI']:Notify("Mission réussie !", "success", 4000)
exports['PipouUI']:Notify("Erreur détectée", "error", 3000)
exports['PipouUI']:Notify("Info simple", "info", 2500)
exports['PipouUI']:Notify("Renforts demandés", "alert-police", 5000)
exports['PipouUI']:Notify("Assistance médicale requise", "alert-ambulance", 5000)
```

---

## ⏳ ProgressBar

```lua
exports['PipouUI']:ProgressBar("Traitement en cours...", 6000, function(cancelled)
    if cancelled then
        print("Action annulée")
    else
        print("Action terminée")
    end
end, true)
```

---

## 📍 Positions disponibles

Tu peux définir la position du menu dès la création :

- `"menu-top-left"`
- `"menu-top-right"` (par défaut)
- `"menu-bottom-left"`
- `"menu-bottom-right"`
- `"menu-center"`

---

## 🗃️ Structure des fichiers

```
pipouui/
├── fxmanifest.lua
├── pipouui.lua
└── html/
    ├── index.html
    ├── style.css
    ├── menu.js
    ├── notify.js
    └── progressbar.js
```

---

## ⚙️ Intégration framework

Compatible avec :
- ✅ QBCore
- ✅ ESX
- ✅ Ressources standalone

---

## 🔄 Nettoyage automatique

Tu peux créer un menu temporaire avec expiration automatique :

```lua
exports['PipouUI']:CreateMenu("Temporaire", "Disparaîtra dans 15s", 15000)
```

---

## 👤 Auteur

- **Développeur principal** : Dostros
- Interface pensée pour être plug-and-play, efficace, rapide, et élégante.

---

## 📄 Licence

Utilisation libre dans les projets communautaires.  
Mention recommandée si réutilisation publique.