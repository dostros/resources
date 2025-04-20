// VARIABLES GLOBALES
let HouseDoorCoords = ''
let GarageDoorCoords = ''
let GarageOutCoords = ''
let pendingDeleteId = null;
let allProperties = [];


// FUNCTION
document.addEventListener("DOMContentLoaded", function () {
    function display(bool) {
        $("body").toggle(bool);
        $("menu").toggle(bool);
    }

    display(false);

    function exit() {
        display(false);
        fetch('https://Pipou-Immo/exit', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }

    window.addEventListener('message', (event) => {
        var item = event.data;

        if (item.type === 'ui') {
            display(item.status);
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
            $("body").toggle(true);
            const menuimmo = document.getElementById("menu");
            if (menuimmo) menuimmo.style.display = "none";

            const menu = document.getElementById("furnitureMenu");
            const container = document.getElementById("furnitureList");

            if (!menu || !container) {
                console.error("[Pipou-Immo] furnitureMenu ou furnitureList introuvable !");
                return;
            }

            container.innerHTML = ""; // Nettoie les anciens meubles

            if (event.data.furnitureList.length === 0) {
                container.innerHTML = "<p>Aucun meuble disponible.</p>";
                return;
            }

            menu.classList.add("visible"); // Affiche le menu
            menu.style.display = "block"; // 🔓 force l'affichage visuellement

            // Remplit le menu avec les meubles disponibles
            event.data.furnitureList.forEach((item) => {
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
            if (event.data.furnitureList.length === 0) {
                container.innerHTML = "<p style='text-align:center;color:white;'>Aucun meuble disponible.</p>";
            }
        }
        if (event.data.type === 'showFurnitureSellMenu') {
            $("body").toggle(true);
        
            const menuimmo = document.getElementById("menu");
            if (menuimmo) menuimmo.style.display = "none";
        
            const menu = document.getElementById("furnitureSellMenu");
            const container = document.getElementById("furnitureSellList");
        
            if (!menu || !container) {
                console.error("[Pipou-Immo] furnitureMenu ou furnitureList introuvable !");
                return;
            }
        
            container.innerHTML = "";
        
            menu.classList.add("visible");
            menu.style.display = "block";
        
            if (event.data.furnitureCategories) {
                populateFurnitureCategories(event.data.furnitureCategories);
        
                // Charge automatiquement tous les meubles par défaut
                loadAllFurniture(event.data.furnitureCategories);
            } else {
                container.innerHTML = "<p style='text-align:center;color:white;'>Aucun meuble disponible.</p>";
            }
        }
        
        
    });

    document.addEventListener('keyup', function (event) {
        if (event.key === 'Escape') exit();
    });

    document.getElementById('close').addEventListener('click', exit);

    document.getElementById('sellProperty').addEventListener('click', function () {
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
        const propertyName = document.getElementById('propertyName').value;
        const coords1 = HouseDoorCoords;
        const coords2 = GarageDoorCoords;
        const coords3 = GarageOutCoords;
        const typeinterior = document.getElementById('interiorType').value;
        const level = document.getElementById('levelproperty').value;

        fetch('https://Pipou-Immo/Pipou-Immo-createProperty', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ propertyName, coords1, coords2, coords3, typeinterior, level })
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
    
        display(false); // 👈 Ferme tout (corps en display: none) + focusNUI off
    
        fetch(`https://${GetParentResourceName()}/closeFurnitureUI`, {
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
    
        const items = furnitureData[category]?.items || [];
    
        items.forEach(item => {
            const div = document.createElement('div');
            div.className = 'furniture-sell-item';
            div.innerHTML = `
                <strong>${item.label}</strong>
                <small>Objet: ${item.object}</small>
                <span class="price">${item.price} $</span>
                <button onclick="placeFurniture('${item.object}', ${item.price})">Placer</button>
            `;
            list.appendChild(div);
        });
    }

    function loadAllFurniture(furnitureData) {
        const list = document.getElementById('furnitureSellList');
        list.innerHTML = '';
    
        Object.keys(furnitureData).forEach((catKey) => {
            furnitureData[catKey].items.forEach(item => {
                const div = document.createElement('div');
                div.className = 'furniture-sell-item';
                div.innerHTML = `
                    <strong>${item.label}</strong>
                    <small>Objet: ${item.object}</small>
                    <span class="price">${item.price} $</span>
                    <button onclick="placeFurniture('${item.object}', ${item.price})">Placer</button>
                `;
                list.appendChild(div);
            });
        });
    }
    
    
      
    
    
      




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
    console.log("je commence à placer")
    fetch(`https://Pipou-Immo/placeFurniture`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ object, label, quantity })
    });
    document.getElementById("furnitureMenu").style.display = "none";
}
