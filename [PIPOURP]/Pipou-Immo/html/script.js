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
  