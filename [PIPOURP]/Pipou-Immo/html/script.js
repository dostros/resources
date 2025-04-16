// VARIABLES GLOBALES
let HouseDoorCoords = ''
let GarageDoorCoords = ''
let GarageOutCoords = ''
let pendingDeleteId = null;

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
            ['properties', 'sellPropertyForm', 'propertyManagement'].forEach(id => {
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

    document.getElementById('toggleTheme').addEventListener('click', () => {
        document.documentElement.classList.toggle('light-theme');
        const isLight = document.documentElement.classList.contains('light-theme');
        toggleBtn.textContent = isLight ? '🌙 Mode sombre' : '🌓 Mode clair';
        localStorage.setItem('theme', isLight ? 'light' : 'dark');
    });

    const savedTheme = localStorage.getItem('theme');
    if (savedTheme === 'light') {
        document.documentElement.classList.add('light-theme');
        document.getElementById('toggleTheme').textContent = '🌙 Mode sombre';
    }

    document.getElementById('manageProperties').addEventListener('click', () => {
        document.getElementById('menu').style.display = 'none';
        document.getElementById('propertyManagement').style.display = 'block';

        const list = document.getElementById('propertyListManage');
        list.innerHTML = '';


        refreshPropertyList();

        
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



function refreshPropertyList() {
    const list = document.getElementById('propertyListManage');
    list.innerHTML = '';

    fetch('https://Pipou-Immo/getAllProperties', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    })
    .then(res => res.json())
    .then(properties => {
        if (!Array.isArray(properties) || properties.length === 0) {
            list.innerHTML = `<li class="empty-message">Aucune propriété enregistrée.</li>`;
            return;
        }

        properties.forEach(prop => {
            const li = document.createElement('li');
            li.innerHTML = `
                <div class="property-header">
                    <div>
                        <strong class="property-name">🏠 ${prop.name}</strong><br/>
                        <span class="property-info">${prop.type}, étage ${prop.level}</span><br/>
                        ${prop.owner_name ? `<span class="owner-tag">👤 ${prop.owner_name}</span>` : '<span class="owner-tag">🔓 Non attribuée</span>'}
                    </div>
                    <div class="property-actions">
                        <input type="number" placeholder="ID joueur" id="assign-${prop.id}" />
                        <button onclick="assignProperty(${prop.id})">Attribuer</button>
                        <button onclick="deleteProperty(${prop.id})">🗑 Supprimer</button>
                    </div>
                </div>
            `;

            list.appendChild(li);
        });
    });
}
