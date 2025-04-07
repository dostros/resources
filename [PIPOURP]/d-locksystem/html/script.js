function deleteRow(button) {
    const row = button.parentNode.parentNode;
    row.parentNode.removeChild(row);
}



document.addEventListener("DOMContentLoaded", function () {
    // Function to display or hide the UI based on a boolean value
    function display(bool) {
        if (bool) {
            $("body").show();
        } else {
            $("body").hide();
        }
    }
    display(false);

    function exit () {
        //display(false)
        fetch('https://d-locksystem/exit', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({}),
        })
            .then((response) => response.json())
            .then((data) => console.log(data))
    }


    // Listen for messages from the server to show or hide the UI
    window.addEventListener('message', (event) => {
        var item = event.data;
        // Display the UI
        if (item.type === 'ui') {
            display(item.status);

        }
        if (item.type ==='addnewdoortotitletable') {
            const table = document.getElementById('doorTable');

            const titlerow = document.createElement('tr');

            titlerow.innerHTML = `
                <th>Nom de la Porte</th>
                <th>Emplacement</th>
                <th>Type de porte</th>
                <th>Automatique</th>
                <th>Statut</th>
                <th>Angle de fermeture</th>
                <th>Job</th>
                <th></th>
            `;

            table.appendChild(titlerow);
        }

        if (item.type ==='addnewdoortotable') {
            let coordonate = item.doorcoords.x.toFixed(2)+", "+ item.doorcoords.y.toFixed(2)+", "+ item.doorcoords.z.toFixed(2)
            const doorData = [
                { 
                    name: item.doorname, 
                    location: coordonate, 
                    type: item.doortype, 
                    automatic: item.doorautomaticornot, 
                    status: item.doorstatus, 
                    angle: item.doorangle, 
                    job: item.doorjob
                },
            ];
            const table = document.getElementById('doorTable');
            doorData.forEach(door => {
                const row = document.createElement('tr');

                row.innerHTML = `
                    <td>${door.name}</td>
                    <td>${door.location}</td>
                    <td>${door.type}</td>
                    <td>${door.automatic}</td>
                    <td>${door.status}</td>
                    <td>${door.angle}</td>
                    <td>${door.job}</td>
                    <td><button onclick="deleteRow(this)">Supprimer</button></td>
                `;

                table.appendChild(row);
            });
        



        }

        window.addEventListener('message', (event) => {
            var item = event.data;
        
            if (item.type === 'coords') {
                
                let namelabel = item.label.split('').filter((char, index) => ![7,8,9,10,11,12].includes(index)).join('');
                let labelcoords = document.getElementById(namelabel+"label");
        
                let roundedX = item.objectcoords.x.toFixed(2);
                let roundedY = item.objectcoords.y.toFixed(2);
                let roundedZ = item.objectcoords.z.toFixed(2);
                labelcoords.textContent = `${roundedX}, ${roundedY}, ${roundedZ}`;

                if (namelabel=="coords1") {
                    entitydoor = item.objectid;
                }
                else {
                    entitydoor2 = item.objectid;
                }
                
            }
        });
        

        document.addEventListener('keyup', function (event) {
            if (event.key === 'Escape') {
                exit();
            }
        });

    });

    // Sélectionner tous les éléments avec la classe 'angle'
    let angleElements = document.querySelectorAll('.chooseangle');

    // Itérer sur chaque élément et ajouter l'écouteur d'événements
    angleElements.forEach(function(angleElement) {
        angleElement.addEventListener('keydown', function (event) {
            if (event.key === 'Enter') {
                event.preventDefault(); // Empêche le comportement par défaut (saut de ligne)

                let value = angleElement.value;
                let elementId = angleElement.id;
                let entitytarget = ''

                // Afficher l'ID de l'élément
                console.log('ID de l\'élément :', elementId," | Valeur: ",value);


                if (elementId=='angleentered') {
                    entitytarget = entitydoor
                }
                else {
                    entitytarget = entitydoor2
                }

                fetch('https://d-locksystem/seedoorangle', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        door: entitytarget,
                        angle: value,
                    }),
                })
                .then(response => response.json())
                .then(data => {
                    console.log('Success:', data);
                })
                .catch((error) => {
                    console.error('Error:', error);
                });
            }
        });
    });


    let confirmationbutton = document.getElementById('confirmation');
        confirmationbutton.addEventListener('click', function(event) {

        let typedoor = document.getElementById("selecttypedoor").value;
        let automaticdoor = document.getElementById("checkboxautomatic").checked;
        if (automaticdoor) {
            console.log(true);
        } else {
            console.log(false);
        }
        let coordsdoor1 = document.getElementById("coords1label").textContent;
        let coordsdoor2 = '';
        let angledoors2 = ""
        if (typedoor === 'doubledoor') {
            coordsdoor2 = document.getElementById("coords2label").textContent;
            angledoors2 = document.getElementById("angleentered2").value;
        }
        let statusdoor = document.getElementById("selectstatusdoor").value;
        let angledoor = document.getElementById("angleentered").value;
        if (angledoor === '') {
            angledoor = 0;
        }

        let jobdoor = document.getElementById("jobentered").value;
        let namedoor = document.getElementById("nameentered").value;

        // Créez l'objet de données à envoyer
        let data = {
            coords: coordsdoor1,
            model: entitydoor,
            status: statusdoor,
            angle: angledoor,
            type: typedoor,
            automatic: automaticdoor,
            job: jobdoor,
            name: namedoor,
        };

        // Ajoutez coords2 uniquement si typedoor est 'doubledoor'
        if (typedoor === 'doubledoor') {
            data.coords2 = coordsdoor2;
            data.angle2 = angledoors2;
            data.model2 = entitydoor2;
        }

        fetch('https://d-locksystem/putalock', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data),
        });
    });

    
    const NewDoorPage = document.getElementById('NewDoorPage')
    NewDoorPage.addEventListener('click', function(event) {
        document.getElementById('TabdoorSystemmenu').style.display='none'
        document.getElementById('LockSystemMenu').style.display='flex'
    });
    const TabDoorPage = document.getElementById('TabDoorPage')
    TabDoorPage.addEventListener('click', function(event) {
        document.getElementById('LockSystemMenu').style.display='none'
        document.getElementById('TabdoorSystemmenu').style.display =('flex')
        document.getElementById('doorTable').innerHTML=''

        fetch('https://d-locksystem/updatetabdoor', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
            }),
        })
        .then(response => response.json())
        .then(data => {
            console.log('Success:', data);
        })
        .catch((error) => {
            console.error('Error:', error);
        });
    });





});

let entitydoor = ''
let entitydoor2 = ''


document.getElementById('angleentered').addEventListener('input', function (event) {
    // Supprimer les caractères non numériques
    this.value = this.value.replace(/[^0-9.]/g, '');
    const parts = this.value.split('.');
    if (parts.length > 2) {
        this.value = parts[0] + '.' + parts.slice(1).join('');
    }
});



document.getElementById('selecttypedoor').addEventListener('change', function (event) {
    var selectedValue = event.target.value;
    let coords2 = document.getElementById('coords2');
    let angle2 = document.getElementById('angle2')

    if (selectedValue === "doubledoor") {
        coords2.classList.add('visible');
        angle2.classList.add('visible');
    } else {
        coords2.classList.remove('visible');
        angle2.classList.remove('visible');
    }
});


let buttonsselect = document.querySelectorAll('.coordsbutton');

buttonsselect.forEach(button => {
    button.addEventListener('click', function () {

        fetch('https://d-locksystem/getcoords', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                coordslot: button.id,
            }),
        })
            .then((response) => response.json())
            // .then((data) => console.log(data))
            // .catch((error) => console.error('Error:', error));

    })
})