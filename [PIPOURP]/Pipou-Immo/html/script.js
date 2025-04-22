// VARIABLES GLOBALES
let HouseDoorCoords = ''
let GarageDoorCoords = ''
let GarageOutCoords = ''
let pendingDeleteId = null;
let allProperties = [];
let currentFurnitureList = [];
let currentSellFurnitureList = [];


// FUNCTION
document.addEventListener("DOMContentLoaded", function () {
    function display(bool) {
        document.body.style.display = bool ? 'flex' : 'none';
    }
    

    hideAllMenus();

    function exit() {
        hideAllMenus()
        fetch('https://Pipou-Immo/exit', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        fetch(`https://${GetParentResourceName()}/clearPreview`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }

    window.addEventListener('message', (event) => {
        var item = event.data;

        if (item.type === 'ui') {
            hideAllMenus();
        
            if (item.status) {
                if (item.page === 'sellPropertyForm') {
                    document.getElementById('sellPropertyForm').style.display = 'block';
                } else {
                    document.getElementById('menu').style.display = 'block';
                }
            }
        }
        
        

        if (item.type === 'setPropertyCoords') {
            display(true);
            switch (item.propertyId) {
                case 'button-inputsetupHouseDoor':
                    HouseDoorCoords = item.coords;
                    document.getElementById('label-inputsetupHouseDoor').innerHTML = '✅';
                    break;
                case 'button-inputsetupGarageDoor':
                    GarageDoorCoords = item.coords;
                    document.getElementById('label-inputsetupGarageDoor').innerHTML = '✅';
                    break;
                case 'button-inputsetupGarageOut':
                    GarageOutCoords = item.coords;
                    document.getElementById('label-inputsetupGarageOut').innerHTML = '✅';
                    break;
            }
        }

        if (item.type === 'notify') {
        }
        if (event.data.type === 'showFurnitureMenu') {
            document.body.style.display = 'flex'; // Affiche le body
            hideAllMenus(); // Ferme tous les autres menus
        
            const menuimmo = document.getElementById("menu");
            if (menuimmo) menuimmo.style.display = "none";
        
            const menu = document.getElementById("furnitureMenu");
            const container = document.getElementById("furnitureList");
        
            if (!menu || !container) {
                console.error("[Pipou-Immo] furnitureMenu ou furnitureList introuvable !");
                return;
            }
        
            container.innerHTML = ""; // Vide les meubles précédents
        
            if (event.data.furnitureList.length === 0) {
                container.innerHTML = "<p>Aucun meuble disponible.</p>";
                return;
            }
        
            menu.classList.add("visible"); // Ajoute la classe visible
            menu.style.display = "block";  // Affiche le menu
        
            // ✅ C’est ici que tu peux capturer la liste pour la recherche
            currentFurnitureList = event.data.furnitureList; // <-- À ajouter si tu veux la recherche
            renderFurnitureList(currentFurnitureList);       // <-- À ajouter aussi (fonction de rendu personnalisée)
        }
        
        if (event.data.type === 'showFurnitureSellMenu') {
            document.body.style.display = 'flex'; // Affiche le body
            hideAllMenus(); // Ferme les autres menus
        
            const menuimmo = document.getElementById("menu");
            if (menuimmo) menuimmo.style.display = "none";
        
            const menu = document.getElementById("furnitureSellMenu");
            const container = document.getElementById("furnitureSellList");
        
            if (!menu || !container) {
                console.error("[Pipou-Immo] furnitureSellMenu ou furnitureSellList introuvable !");
                return;
            }
        
            container.innerHTML = ""; // Vide la liste actuelle
        
            menu.classList.add("visible");
            menu.style.display = "block";
        
            // 📦 Gestion des catégories + affichage initial
            if (event.data.furnitureCategories) {
                populateFurnitureCategories(event.data.furnitureCategories); // Affiche les catégories
        
                // Charge tous les meubles dès l'ouverture
                loadAllFurniture(event.data.furnitureCategories);
            } else {
                container.innerHTML = "<p style='text-align:center;color:white;'>Aucun meuble disponible.</p>";
            }
        }
        
        
        
    });

    document.addEventListener('keyup', function (event) {
        if (event.key === 'Escape') {
            hideAllMenus();
            fetch('https://Pipou-Immo/exit', { method: 'POST' });
            fetch(`https://${GetParentResourceName()}/clearPreview`, { method: 'POST' });
        }
    });
    

    document.getElementById('close').addEventListener('click', exit);

    document.getElementById('sellProperty').addEventListener('click', function () {
        hideAllMenus();
        document.getElementById('sellPropertyForm').style.display = 'block';
        document.getElementById('menu').style.display = 'none';

        fetch('https://Pipou-Immo/Pipou-Immo-getinteriortypes', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        })
        .then((res) => res.json())
        .then((data) => {
            const select = document.getElementById('interiorType');
            select.innerHTML = '<option value="none">Type d\'intérieur</option>';
            data.forEach(type => {
                const option = document.createElement('option');
                option.value = type.name;
                option.textContent = type.label;
                select.appendChild(option);
            });
        });
    });

    document.querySelectorAll('.backbutton').forEach(function (btn) {
        btn.addEventListener('click', function () {
            hideAllMenus();
            ['sellPropertyForm', 'propertyManagement'].forEach(id => {
                document.getElementById(id).style.display = 'none';
            });
            document.getElementById('menu').style.display = 'block';
        });
    });

    document.querySelectorAll('.setpropertycoords').forEach(btn => {
        btn.addEventListener('click', function () {
            const propertyId = btn.getAttribute('id');
            exit();

            fetch('https://Pipou-Immo/Pipou-Immo-setPropertyCoords', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ propertyId: propertyId })
            });
        });
    });

    document.getElementById('confirmCreationofProperty').addEventListener('click', function () {
        document.getElementById('confirmationBox').style.display = 'block';
    });

    document.getElementById('confirmYes').addEventListener('click', function () {
        document.getElementById('confirmationBox').style.display = 'none';
    
        const propertyName = document.getElementById('propertyName').value.trim();
        const coords1 = HouseDoorCoords;
        const coords2 = GarageDoorCoords;
        const coords3 = GarageOutCoords;
        const typeinterior = document.getElementById('interiorType').value;
        const level = document.getElementById('levelproperty').value;
    
        // Vérification du nom
        if (!propertyName) {
            notifyNUI("❌ Le nom de la propriété est requis.");
            return;
        }
    
        // Vérification du type d’intérieur
        if (!typeinterior || typeinterior === 'none') {
            notifyNUI("❌ Le type d’intérieur est requis.");
            return;
        }
    
        // Vérification des coordonnées de la maison
        if (!coords1 || typeof coords1 !== 'object' || coords1.x === undefined || coords1.y === undefined || coords1.z === undefined) {
            notifyNUI("❌ Le point d’entrée de la maison est requis.");
            return;
        }
    
        // Vérification des coordonnées du garage
        if (!coords2 || typeof coords2 !== 'object' || coords2.x === undefined || coords2.y === undefined || coords2.z === undefined) {
            notifyNUI("❌ Le point du garage est requis.");
            return;
        }
    
        // Vérification des coordonnées de sortie du garage
        if (!coords3 || typeof coords3 !== 'object' || coords3.x === undefined || coords3.y === undefined || coords3.z === undefined) {
            notifyNUI("❌ Le point de sortie du garage est requis.");
            return;
        }
    
        // Vérification du niveau (facultatif, mais on force un 0 si vide)
        const parsedLevel = parseInt(level);
        const finalLevel = isNaN(parsedLevel) ? 0 : parsedLevel;
    
        fetch('https://Pipou-Immo/Pipou-Immo-createProperty', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                propertyName,
                coords1,
                coords2,
                coords3,
                typeinterior,
                level: finalLevel
            })
        });
    });
    
    

    document.getElementById('confirmNo').addEventListener('click', function () {
        document.getElementById('confirmationBox').style.display = 'none';
    });


    document.getElementById('manageProperties').addEventListener('click', () => {
        document.getElementById('menu').style.display = 'none';
        document.getElementById('propertyManagement').style.display = 'block';
      
        fetch('https://Pipou-Immo/getAllProperties', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({})
        })
          .then(res => res.json())
          .then(data => {
            allProperties = data;
            refreshPropertyList();
        });
    });
      

    document.getElementById('deleteConfirmYes').addEventListener('click', () => {
        if (!pendingDeleteId) return;
    
        fetch('https://Pipou-Immo/deleteProperty', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id: pendingDeleteId })
        })
        .then(res => res.json())
        .then(res => {
            if (res.success) {
                document.getElementById('deleteConfirmationBox').style.display = 'none'; // Fermer la boîte
                pendingDeleteId = null;
                refreshPropertyList(); // Réactualiser la liste
            } else {
            }
        });
    });
    

    document.getElementById('deleteConfirmNo').addEventListener('click', () => {
        document.getElementById('deleteConfirmationBox').style.display = 'none';
        pendingDeleteId = null;
    });

    document.getElementById('propertySearch').addEventListener('input', () => {
        const query = document.getElementById('propertySearch').value.toLowerCase();
        const filtered = allProperties.filter(p =>
          p.name.toLowerCase().includes(query)
        );
        refreshPropertyList(filtered);
    });

    window.togglePropertyActions = function(headerDiv, event) {
        const tag = event?.target?.tagName?.toLowerCase();
        if (tag === 'button' || tag === 'input' || event?.target?.classList.contains('property-actions')) {
            return;
        }
    
        const actions = headerDiv.querySelector('.property-actions');
        if (actions.classList.contains('hidden')) {
            actions.classList.remove('hidden');
            actions.classList.add('expanded');
        } else {
            actions.classList.remove('expanded');
            actions.classList.add('hidden');
        }
    }
    
    document.getElementById('closeFurnitureButton').addEventListener('click', closeFurnitureUI);

    function closeFurnitureUI() {
        const menu = document.getElementById("furnitureMenu");
    
        if (menu) {
            menu.classList.remove("visible");
            menu.style.display = "none";
        }
    
        hideAllMenus(); 

    
        fetch(`https://${GetParentResourceName()}/closeFurnitureUI`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        fetch(`https://${GetParentResourceName()}/clearPreview`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        
    }


    document.getElementById('closeFurnitureSellButton').addEventListener('click', closeFurnitureSellUI);

    function closeFurnitureSellUI() {
        const menu = document.getElementById("furnitureSellMenu");
    
        if (menu) {
            menu.classList.remove("visible");
            menu.style.display = "none";
        }
    
        hideAllMenus();
    
        fetch(`https://${GetParentResourceName()}/closeFurnitureUI`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        fetch(`https://${GetParentResourceName()}/clearPreview`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        
    }





    document.querySelectorAll('.category-button').forEach(button => {
        button.addEventListener('click', () => {
          // Active button UI
          document.querySelectorAll('.category-button').forEach(b => b.classList.remove('active'));
          button.classList.add('active');
      
          const category = button.getAttribute('data-category');
          document.querySelectorAll('.furniture-sell-item').forEach(item => {
            const itemCategory = item.getAttribute('data-category');
            if (category === 'all' || itemCategory === category) {
              item.style.display = '';
            } else {
              item.style.display = 'none';
            }
          });
        });
    });

    function populateFurnitureCategories(furnitureData) {
        const categoryBar = document.getElementById('furnitureCategories');
        categoryBar.innerHTML = ''; 
    
        const allBtn = document.createElement('button');
        allBtn.className = 'category-button active';
        allBtn.textContent = 'Tous';
        allBtn.dataset.category = 'all';
        allBtn.addEventListener('click', () => {
            document.querySelectorAll('.category-button').forEach(btn => btn.classList.remove('active'));
            allBtn.classList.add('active');
            loadAllFurniture(furnitureData);
        });
        categoryBar.appendChild(allBtn);
    
        Object.keys(furnitureData).forEach((key) => {
            const button = document.createElement('button');
            button.className = 'category-button';
            button.textContent = furnitureData[key].label || key;
            button.dataset.category = key;
    
            button.addEventListener('click', () => {
                document.querySelectorAll('.category-button').forEach(btn => btn.classList.remove('active'));
                button.classList.add('active');
                loadFurnitureCategory(key, furnitureData);
            });
    
            categoryBar.appendChild(button);
        });
    }
    
    
    function loadFurnitureCategory(category, furnitureData) {
        const list = document.getElementById('furnitureSellList');
        list.innerHTML = '';

        fetch(`https://${GetParentResourceName()}/clearPreview`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        
    
        const items = furnitureData[category]?.items || [];
    
        items.forEach(item => {
            const div = document.createElement('div');
            div.className = 'furniture-sell-item';
            div.innerHTML = `
                <strong>${item.label}</strong>
                <small>Objet: ${item.object}</small>
                <span class="price">${item.price} $</span>
                <button onclick="previsualisatinFurniture('${item.object}', ${item.price})">Aperçu</button>
                <button onclick="buyFurniture('${item.object}', ${item.price})">Acheter</button>
            `;
            list.appendChild(div);
        });
    }

    function loadAllFurniture(furnitureData) {
        const list = document.getElementById('furnitureSellList');
        list.innerHTML = '';
    
        fetch(`https://${GetParentResourceName()}/clearPreview`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    
        // Préparation de la liste complète pour la recherche
        const allItems = [];
    
        Object.keys(furnitureData).forEach((catKey) => {
            furnitureData[catKey].items.forEach(item => {
                const div = document.createElement('div');
                div.className = 'furniture-sell-item';
                div.setAttribute('data-category', catKey); // utile pour filtrer par catégorie
                div.innerHTML = `
                    <strong>${item.label}</strong>
                    <small>Objet: ${item.object}</small>
                    <span class="price">${item.price} $</span>
                    <button onclick="previsualisatinFurniture('${item.object}', ${item.price})">Aperçu</button>
                    <button onclick="buyFurniture('${item.object}', ${item.price})">Acheter</button>
                `;
                list.appendChild(div);
    
                // Stocker dans une liste globale pour la recherche
                allItems.push({
                    label: item.label,
                    object: item.object,
                    quantity: item.quantity || 1,
                    price: item.price,
                    category: catKey
                });
            });
        });
    
        // ⬅️ Très important : met à jour la liste utilisée par le champ de recherche
        currentSellFurnitureList = allItems;
        renderSellFurnitureList(allItems);
    }
    
    
    function hideAllMenus() {
        const allMenuIds = [
            'menu',
            'sellPropertyForm',
            'propertyManagement',
            'confirmationBox',
            'deleteConfirmationBox',
            'furnitureMenu',
            'furnitureSellMenu'
        ];
    
        allMenuIds.forEach(id => {
            const el = document.getElementById(id);
            if (el) el.style.display = 'none';
        });
    
        document.body.style.display = 'flex'; // Important ! Ne jamais cacher tout le body
    }

    function notifyNUI(message, type = "error") {
        fetch(`https://${GetParentResourceName()}/notify`, {
            method: "POST",
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ message, type })
        });
    }
    

    function renderFurnitureList(list) {
        const container = document.getElementById("furnitureList");
        container.innerHTML = "";
    
        if (list.length === 0) {
            container.innerHTML = "<p>Aucun meuble disponible.</p>";
            return;
        }
    
        list.forEach((item) => {
            const div = document.createElement("div");
            div.className = "furniture-item";
            div.innerHTML = `
                <strong>${item.label}</strong>
                <small>${item.object}</small>
                <span class="quantity">Quantité : ${item.quantity}</span>
                <button onclick="placeFurniture('${item.object}', '${item.label}', ${item.quantity})">Placer</button>
            `;
            container.appendChild(div);
        });
    }

    document.getElementById('furnitureSearch').addEventListener('input', () => {
        const query = document.getElementById('furnitureSearch').value.toLowerCase();
        const filtered = currentFurnitureList.filter(item =>
            item.label.toLowerCase().includes(query)
        );
        renderFurnitureList(filtered);
    });
    
    function renderSellFurnitureList(list) {
        const container = document.getElementById("furnitureSellList");
        container.innerHTML = "";
    
        if (list.length === 0) {
            container.innerHTML = "<p>Aucun meuble disponible.</p>";
            return;
        }
    
        list.forEach((item) => {
            const div = document.createElement("div");
            div.className = "furniture-item";
            div.innerHTML = `
                <strong>${item.label}</strong>
                <small>${item.object}</small>
                <span class="quantity">Quantité : ${item.quantity}</span>
                <button onclick="sellFurniture('${item.object}', '${item.label}', ${item.quantity})">Vendre</button>
            `;
            container.appendChild(div);
        });
    }
    
    
    document.getElementById('furnitureSellSearch').addEventListener('input', () => {
        const query = document.getElementById('furnitureSellSearch').value.toLowerCase();
        const filtered = currentSellFurnitureList.filter(item =>
            item.label.toLowerCase().includes(query)
        );
        renderSellFurnitureList(filtered);
    });
    
      
    
    


});

// RENDRE GLOBAL POUR HTML
window.deleteProperty = function (id) {
    pendingDeleteId = id;
    document.getElementById('deleteConfirmationBox').style.display = 'block';
};

window.assignProperty = function (id) {
    const input = document.getElementById(`assign-${id}`);
    const targetId = input.value;

    if (!targetId || isNaN(targetId)) {
        return;
    }

    fetch('https://Pipou-Immo/assignPropertyToPlayerId', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: id, target: parseInt(targetId) })
    })
    .then(res => res.json())
};



function refreshPropertyList(filteredList = allProperties) {
    const list = document.getElementById('propertyListManage');
    list.innerHTML = '';
  
    if (!filteredList.length) {
      list.innerHTML = `<li class="empty-message">Aucune propriété trouvée.</li>`;
      return;
    }
  
    filteredList.forEach(prop => {
        const li = document.createElement('li');
        li.classList.add('property-item');
        li.innerHTML = `
          <div class="property-header" onclick="togglePropertyActions(this, event)">
            <div>
              <strong class="property-name">🏠 ${prop.name}</strong><br/>
              <span class="property-info">${prop.type}, étage ${prop.level}</span><br/>
              ${prop.owner_name ? `<span class="owner-tag">👤 ${prop.owner_name}</span>` : '<span class="owner-tag">🔓 Non attribuée</span>'}
            </div>
            <div class="property-actions hidden">
              <input type="number" placeholder="ID joueur" id="assign-${prop.id}" />
              <button onclick="assignProperty(${prop.id})">Attribuer</button>
              <button onclick="deleteProperty(${prop.id})">🗑 Supprimer</button>
            </div>
          </div>
        `;
        list.appendChild(li);
    });
      
}

window.placeFurniture = function(object, label, quantity) {
    fetch(`https://Pipou-Immo/placeFurniture`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ object, label, quantity })
    });
    document.getElementById("furnitureMenu").style.display = "none";
}


window.previsualisatinFurniture = function(object, label, quantity) {
    fetch(`https://Pipou-Immo/previsualisatinFurniture`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ object, label, quantity })
    });
}

window.buyFurniture = function(objectName, price) {
    fetch(`https://${GetParentResourceName()}/PipouImmo:buyFurniture`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            furnitureName: objectName,
            label: objectName,
            price: price
        })
    })
    .then(res => res.json())
}