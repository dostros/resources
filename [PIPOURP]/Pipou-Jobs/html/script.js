document.addEventListener("DOMContentLoaded", function () {
    const tabs = document.querySelectorAll(".tab-button");
    const panels = document.querySelectorAll(".tab-panel");

    tabs.forEach(tab => {
        tab.addEventListener("click", function () {
            const target = this.getAttribute("data-target");

            // Retirer la classe active de tous les boutons et panneaux
            tabs.forEach(t => t.classList.remove("active"));
            panels.forEach(p => p.classList.remove("active"));

            // Ajouter la classe active sur l'élément cliqué
            this.classList.add("active");
            document.getElementById(target).classList.add("active");


            // Récupérer la liste des employés/banque/grade/annonce

            fetch('https://Pipou-Jobs/getJobInfo', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    JobId: currentJobId,
                }),
            })
                .then((response) => response.json())
                .then((data) => console.log(data))
                .catch((error) => console.error('Error:', error));


        });
    });

    // Déclencher un clic sur l'onglet "Employés" au chargement
    document.querySelector(".tab-button.active").click();

});


///////////////////////////////////////////////////////////////////////////////////////
currentjobLabel = null;
currentJobId = null;

document.addEventListener("DOMContentLoaded", function () {
   

    function display(bool,joblabel, jobid) {
        if (bool) {
            $("body").show();
            document.querySelector(".header").textContent = "BOSS MENU - " + joblabel;
            currentjobLabel = joblabel;
            currentJobId = jobid;
        } else {
            $("body").hide();
        }
    }

    //display(false)

    function exit () {


        //display(false)

        fetch('https://Pipou-Jobs/exit', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({}),
        })
            .then((response) => response.json())
            .then((data) => console.log(data))
            .catch((error) => console.error('Error:', error));
    }


    // Listen for messages from the server to show or hide the UI
    window.addEventListener('message', (event) => {

        var item = event.data;
        // Display the UI
        if (item.type === 'ui') {
            display(item.status, item.joblabel, item.jobid);
        }

        if (event.data.type === 'ui:jobinfo') {
            const employeeList = event.data.listemployee; // Liste des employés
            const jobLabel = event.data.joblabel;
    
            // Afficher le job (par exemple 'Timber') dans l'interface
            //document.getElementById('jobLabel').textContent = `Job: ${jobLabel}`;
    
            // Accéder à la table où les employés seront ajoutés
            const employeeTableBody = document.querySelector('#employes table tbody');
            
            // Réinitialiser la table pour s'assurer qu'on n'ajoute pas plusieurs fois
            employeeTableBody.innerHTML = ''; 
    
            // Ajouter les employés dans la table
            employeeList.forEach(emp => {
                const row = document.createElement('tr'); // Créer une nouvelle ligne pour chaque employé
    
                // Créer des cellules pour le nom, le grade et le bouton "Licencier"
                const nameCell = document.createElement('td');
                nameCell.textContent = emp.name; // Ajouter le nom de l'employé
    
                const gradeCell = document.createElement('td');
                gradeCell.textContent = emp.grade_name; // Ajouter le grade de l'employé
    
                const actionCell = document.createElement('td');
                const fireButton = document.createElement('button');
                fireButton.textContent = 'Licencier'; // Texte du bouton
    
                // Ajouter un événement pour "Licencier" (éventuellement en envoyant une action à Lua)
                fireButton.addEventListener('click', function () {
                    showModal(`Voulez-vous vraiment licencier ${emp.name} ?`, () => {
                        console.log(`${emp.name} a été licencié.`);
                        // Ici, tu pourrais déclencher un événement vers Lua si besoin
                        // fetch('https://Pipou-Jobs/fire', { ... })
                    });
                });
                
    
                // Ajouter les cellules à la ligne
                actionCell.appendChild(fireButton);
                row.appendChild(nameCell);
                row.appendChild(gradeCell);
                row.appendChild(actionCell);
    
                // Ajouter la ligne au corps de la table
                employeeTableBody.appendChild(row);
            });
        }







    })

    document.addEventListener('keyup', function (event) {
        if (event.key === 'Escape' || event.key === 'Backspace') {
            exit();
        }
    });

    function showModal(message, onConfirm) {
        // Créer les éléments
        const overlay = document.createElement('div');
        overlay.classList.add('modal-overlay');
    
        const modal = document.createElement('div');
        modal.classList.add('modal');
    
        const title = document.createElement('h3');
        title.textContent = message;
    
        const buttonsDiv = document.createElement('div');
        buttonsDiv.classList.add('modal-buttons');
    
        const confirmBtn = document.createElement('button');
        confirmBtn.textContent = 'Confirmer';
        confirmBtn.classList.add('confirm');
    
        const cancelBtn = document.createElement('button');
        cancelBtn.textContent = 'Annuler';
        cancelBtn.classList.add('cancel');
    
        // Événements
        confirmBtn.onclick = () => {
            onConfirm();
            document.body.removeChild(overlay);
        };
    
        cancelBtn.onclick = () => {
            document.body.removeChild(overlay);
        };
    
        // Assemble
        buttonsDiv.appendChild(confirmBtn);
        buttonsDiv.appendChild(cancelBtn);
        modal.appendChild(title);
        modal.appendChild(buttonsDiv);
        overlay.appendChild(modal);
        document.body.appendChild(overlay);
    }
    






});

