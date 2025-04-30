# PipouUI

**PipouUI** est une interface utilisateur modulaire et légère pour FiveM. Elle remplace des solutions comme RageUI, NativeUI ou les notifications/progressbars de `qb-core`.

---

## ✨ Fonctions disponibles

- ✅ Menus dynamiques (simples, listes, sliders, checkbox, onglets)
- 🔔 Notifications NUI customisables (success, error, info, alerte police, ambulance)
- ⏳ Barre de progression (avec ou sans annulation)
- 🎮 Navigation clavier complète
- ⚡ Haute performance (aucune boucle inutile, aucun polling)

---

## 📦 Installation

1. Dépose le dossier dans `resources/` de ton serveur.
2. Ajoute dans `server.cfg` :

```cfg
ensure pipouui
```

---

## 📘 API Lua

### Créer et afficher un menu simple
```lua
local id = exports['PipouUI']:CreateMenu("Garage", "Choisissez un véhicule")
exports['PipouUI']:AddButton(id, "Véhicule A", function()
    print("A sélectionné")
end)
exports['PipouUI']:OpenMenu(id)
```

### Ouvrir une notification
```lua
exports['PipouUI']:Notify("Véhicule rangé", "success", 3000)
```

### Afficher une barre de chargement
```lua
exports['PipouUI']:ProgressBar("Chargement...", 5000, function(cancelled)
    if not cancelled then print("Terminé") end
end, true)
```

---

## 🖥️ Structure des fichiers

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

## 🧪 Compatible

- Client `qb-core`, `esx` ou autonome.
- 1080p, 1440p, 4K avec responsive intégré.

---

## 🛠️ Contributeur principal

**Dostros** – pipouUI est conçu pour des performances modernes et une intégration simple.

---

## 📄 Licence

Libre d'utilisation dans des projets communautaires. Mention appréciée en cas de réutilisation.
