# 📦 PipouUI

**PipouUI** est une interface utilisateur légère et dynamique conçue pour FiveM. Elle permet de créer des menus interactifs (boutons, sliders, checkboxes, tabs, listes, entrées, barre de recherche, notifications, progressbars) de manière élégante et intuitive — intégralement en HTML/CSS/JS, avec une API Lua simple côté serveur.

---

## ✨ Fonctionnalités

- 🔘 Menus dynamiques avec **navigation clavier**
- ✅ Support des **checkboxes**, **sliders**, **sections**, **entrées**
- 🔍 **Recherche interactive** dans les menus
- 🗂️ Système de **tabs**
- 🔔 **Notifications contextuelles**
- ⏳ **Progressbar** personnalisée
- 🧠 Historique de navigation
- 🎨 Interface adaptative (1080p → 4K)

---

## 📁 Structure du projet

```plaintext
pipouui/
│
├── html/
│   ├── index.html          # Interface HTML principale
│   ├── style.css           # Feuille de style (dark & responsive)
│   ├── menu.js             # Logique des menus
│   ├── notify.js           # Système de notifications
│   ├── progressbar.js      # Barre de progression
│
├── fxmanifest.lua          # Déclaration de la ressource
└── pipouui.lua             # API Lua côté client/serveur
```

---

## 🧩 Installation

1. Glisse le dossier `pipouui/` dans ton répertoire `resources/`
2. Ajoute dans ton `server.cfg` :

```cfg
ensure pipouui
```

3. Assure-toi que ta ressource utilise le NUI :

```lua
-- Exemple côté client
exports['PipouUI']:OpenSimpleMenu(...)
exports['PipouUI']:Notify(...)
```

---

## 🧪 Exemples d'utilisation

### ➕ Menu simple

```lua
exports['PipouUI']:OpenSimpleMenu("Actions", "Choisissez une option", {
    { label = "Soigner",        type = "button" },
    { label = "Godmode",        type = "checkbox", checked = true },
    { label = "Vie max",        type = "slider", min = 0, max = 200, value = 100 },
    { label = "🔍",             type = "searchinput", placeholder = "Rechercher une action" }
})
```

### ✅ Recevoir l'action sélectionnée

```lua
RegisterNUICallback("selectOption", function(data, cb)
    local idx = data.index
    print("Option sélectionnée :", idx)
    cb({ close = true }) -- ferme le menu si voulu
end)
```

### 📄 Liste simple

```lua
exports['PipouUI']:OpenListMenu("Choix", "Sélectionnez un item", { "Item 1", "Item 2", "Item 3" })

RegisterNUICallback("selectListOption", function(data, cb)
    local choice = data.index -- index de l'élément choisi
    print("Choix :", choice)
    cb({})
end)
```

### 🔁 Tabs

```lua
exports['PipouUI']:OpenTabbedMenu("Menu Tabulé", "Choisissez", {
    {
        label = "Armes",
        options = { { label = "AK-47" }, { label = "M4A1" } }
    },
    {
        label = "Véhicules",
        options = { { label = "Sultan" }, { label = "Buffalo" } }
    }
})
```

---

## 🔔 Notifications

```lua
exports['PipouUI']:Notify("Bien joué !", "success")
exports['PipouUI']:Notify("Erreur fatale", "error")
exports['PipouUI']:Notify("Vous avez reçu un message", "info")
exports['PipouUI']:Notify("Demande POLICE", "alert-police")
exports['PipouUI']:Notify("Demande EMS", "alert-ambulance")
```

---

## ⏳ Barre de progression

```lua
exports['PipouUI']:ProgressBar("Recherche en cours...", 5000)

-- Côté client JS → déclenché automatiquement
SendNUIMessage({
    action = "SHOW_PROGRESSBAR",
    text = "Chargement...",
    duration = 5000
})
```

---

## 🧩 API Lua complète

| Fonction                          | Description                              |
|----------------------------------|------------------------------------------|
| `OpenSimpleMenu(title, sub, options)` | Ouvre un menu basique |
| `OpenListMenu(title, sub, list)` | Affiche une liste d’options |
| `OpenTabbedMenu(title, sub, tabs)` | Menu avec plusieurs onglets |
| `Notify(message, type)`          | Affiche une notification |
| `ProgressBar(message, duration)` | Affiche une progressbar |

---

## 🎨 Personnalisation

- **CSS adaptatif** : ajustements automatiques pour 1080p, 2K et 4K
- **Couleurs modifiables** : modifie `style.css` (ex. couleurs `#ffa726`, `#ff9800`, etc.)
- **Emplacement dynamique** : `position = "menu-top-left"`, `"menu-center"`, etc.

---

## 📷 Aperçu

![Aperçu PipouUI Menu](https://user-images.githubusercontent.com/example/mockup.png)

---

## 🛠️ À venir

- 🎯 Drag & drop
- 🔄 Menus persistants
- 🌐 Localisation multi-langues
- 🧪 Tests automatisés

---

## 🧾 Licence

MIT © 2025 – *Fait avec ❤️ pour la communauté FiveM*
