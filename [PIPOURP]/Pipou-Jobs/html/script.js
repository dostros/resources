document.addEventListener("DOMContentLoaded", function () {
    const tabs = document.querySelectorAll(".tab-button");
    const panels = document.querySelectorAll(".tab-panel");

    // Récupérer et afficher les employés lorsque l'onglet 'Employés' est actif
    tabs.forEach(tab => {
        tab.addEventListener("click", function () {
            const target = this.getAttribute("data-target");

            // Retirer la classe active de tous les boutons et panneaux
            tabs.forEach(t => t.classList.remove("active"));
            panels.forEach(p => p.classList.remove("active"));

            // Ajouter la classe active sur l'élément cliqué
            this.classList.add("active");
            document.getElementById(target).classList.add("active");

            // Actualiser les données lorsque l'onglet approprié est sélectionné
            if (target === "employes") {
                updateEmployees();
            }
            if (target === "banque") {
                updateBanque();
            }
            if (target === "grade") {
                updateGrade();
            }
        });
    });

    // Déclencher un clic sur l'onglet "Employés" au chargement pour afficher les employés dès l'ouverture
    document.querySelector(".tab-button.active").click();
});

setInterval(() => {
    // Vérifier si l'onglet "Employés" est actif avant de mettre à jour les employés
    if (document.querySelector(".tab-button.active").getAttribute("data-target") === "employes") {
        updateEmployees();  // Mise à jour des employés si l'onglet est actif
    }
}, 60000);  // Mise à jour toutes les 60 secondes

// Fonction pour récupérer et afficher les employés
function updateEmployees() {
    // Vérifier que `currentJobId` est bien défini
    if (!currentJobId) {
        console.error("JobId non défini");
        return;
    }

    fetch('https://Pipou-Jobs/getJobInfo', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            JobId: currentJobId,  // Assurer que currentJobId est bien défini
        }),
    })
    .then((response) => response.json())
    .catch((error) => console.error('Erreur lors de la récupération des employés :', error));
}

// Fonction showModal mise à jour pour accepter firstName, lastName et name
function showModal(fullName, jobid) {

    const overlay = document.createElement('div');
    overlay.classList.add('modal-overlay');

    const modal = document.createElement('div');
    modal.classList.add('modal');

    const title = document.createElement('h3');
    title.textContent = `Voulez-vous vraiment licencier ${fullName} ?`;  // Utilisation du nom complet

    const buttonsDiv = document.createElement('div');
    buttonsDiv.classList.add('modal-buttons');

    const confirmBtn = document.createElement('button');
    confirmBtn.textContent = 'Confirmer';
    confirmBtn.classList.add('confirm');

    const cancelBtn = document.createElement('button');
    cancelBtn.textContent = 'Annuler';
    cancelBtn.classList.add('cancel');

    confirmBtn.onclick = () => {
        console.log(`${fullName} a été licencié.`);
    
        // Envoi de l'information vers Lua pour traiter le licenciement
        fetch('https://Pipou-Jobs/FireSomeone', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                fullName: fullName,
                jobname: jobid, 
            })
        }).then((response) => {
            if (response.ok) {
                console.log('Licenciement effectué pour :', fullName);
            } else {
                console.error('Erreur lors du licenciement');
            }
        });
        document.body.removeChild(overlay);
    };

    cancelBtn.onclick = () => {
        document.body.removeChild(overlay);
    };

    buttonsDiv.appendChild(confirmBtn);
    buttonsDiv.appendChild(cancelBtn);
    modal.appendChild(title);
    modal.appendChild(buttonsDiv);
    overlay.appendChild(modal);
    document.body.appendChild(overlay);
}



// Fonction pour récupérer les informations de la banque
// Fonction pour récupérer et afficher le solde de la banque
function updateBanque() {
    // Appel à un service ou une API pour obtenir le solde de la banque (ici simulé par un exemple)
    fetch('https://Pipou-Jobs/getBanqueInfo', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            JobId: currentJobId,  // Utiliser currentJobId ici pour savoir de quelle entreprise il s'agit
        }),
    })
    .then((response) => response.json())
    .then((data) => {
        const solde = data.solde || 0;  // Assumer que l'API retourne un champ `solde`
        document.getElementById('banque-solde').textContent = formatCurrency(solde); // Formatage du montant
    })
    .catch((error) => {
        console.error('Erreur lors de la récupération du solde de la banque :', error);
        document.getElementById('banque-solde').textContent = "Erreur de chargement";
    });
}

function updateGrade() {
    // Appel à un service ou une API pour obtenir le solde de la banque (ici simulé par un exemple)
    fetch('https://Pipou-Jobs/getGradeInfo', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            JobId: currentJobId,
            }),
            })
            .then((response) => response.json())
            .then((data) => {
                const grades = data.grades || [];
                const gradeTableBody = document.querySelector('#grade table tbody');
                gradeTableBody.innerHTML = ''; // Réinitialiser la table avant d'ajouter les grades

                grades.forEach(grade => {
                    const row = document.createElement('tr');
                    const gradeCell = document.createElement('td');
                    gradeCell.textContent = grade.name; // Nom du grade
                    const salaryCell = document.createElement('td');
                    salaryCell.textContent = `${grade.payment} $`; // Salaire du grade
                    const actionCell = document.createElement('td');
                    const modifyButton = document.createElement('button');
                    modifyButton.textContent = 'Modifier';

                    // Ajouter un événement pour modifier le grade
                    modifyButton.addEventListener('click', function () {
                    showEditGradeModal(grade,currentJobId), () => {
                        console.log(`Grade ${grade.name} modifié.`);
                        // Ici, tu pourrais déclencher un événement vers Lua si besoin

                        fetch('https://Pipou-Jobs/modifyGrade', { method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                            },
                            body: JSON.stringify({
                                JobId: currentJobId,
                                }), })   
                            .then((response) => response.json())
                            .then((data) => {
                                console.log('Grade modifié :', data);
                                // Mettre à jour l'affichage ou faire autre chose après la modification
                            })
                            .catch((error) => console.error('Erreur lors de la modification du grade :', error)); 
                        };
                    });

                    actionCell.appendChild(modifyButton);
                    row.appendChild(gradeCell);
                    row.appendChild(salaryCell);
                    row.appendChild(actionCell);
                    gradeTableBody.appendChild(row);
                }
            );
        }   
)};

// Fonction pour formater le solde comme une devise
function formatCurrency(amount) {
    return amount.toLocaleString('fr-FR', {
        style: 'currency',
        currency: 'USD'
    });
}

// Actualiser le solde lorsque l'on clique sur le bouton "Actualiser"
document.getElementById('actualiser-solde').addEventListener('click', function() {
    updateBanque();
});

// Appeler la fonction pour initialiser l'affichage du solde lors de l'ouverture de l'onglet
if (document.querySelector(".tab-button.active").getAttribute("data-target") === "banque") {
    updateBanque();  // Mettre à jour les informations de la banque
}


///////////////////////////////////////////////////////////////////////////////////////
// Gérer l'affichage de l'interface

let currentJobLabel = null;
let currentJobId = null;

function display(bool, joblabel, jobid) {
    if (bool) {
        $("body").show();
        document.querySelector(".header").textContent = "BOSS MENU - " + joblabel;
        currentJobLabel = joblabel;
        currentJobId = jobid;
        updateEmployees();  // Mettre à jour les employés dès que l'UI est affichée
    } else {
        $("body").hide();
    }
}

display(false);

// Événement pour fermer l'UI
function exit() {
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

// Écouteur d'événements de messages pour afficher ou masquer l'UI
window.addEventListener('message', (event) => {
    const item = event.data;

    if (item.type === 'ui') {
        display(item.status, item.joblabel, item.jobid);
    }

    if (event.data.type === 'ui:jobinfo') {
        const employeeList = event.data.listemployee;
        const jobLabel = event.data.joblabel;
        const employeeTableBody = document.querySelector('#employes table tbody');
        employeeTableBody.innerHTML = ''; // Réinitialiser la table
    
        employeeList.forEach(emp => {
            const row = document.createElement('tr');
            const nameCell = document.createElement('td');
            nameCell.textContent = emp.name; // Afficher le nom de l'employé
            const gradeCell = document.createElement('td');
            gradeCell.textContent = emp.grade_name; // Afficher le grade de l'employé
            const actionCell = document.createElement('td');
            const fireButton = document.createElement('button');
            fireButton.textContent = 'Licencier';
    
            fireButton.addEventListener('click', function () {
                // On passe les informations supplémentaires à la fonction showModal
                showModal(emp.name, jobLabel)
            });
    
            actionCell.appendChild(fireButton);
            row.appendChild(nameCell);
            row.appendChild(gradeCell);
            row.appendChild(actionCell);
            employeeTableBody.appendChild(row);
        });
    }
    

    if (event.data.type === 'ui:banqueinfo') {
        const bankaccount = event.data.bankaccount;

        document.getElementById('banque-solde').textContent = formatCurrency(bankaccount);
       
    }
});

// Fermeture avec la touche ESC
document.addEventListener('keyup', function (event) {
    const activeElement = document.activeElement;
    const isInputFocused = activeElement && (
        activeElement.tagName === 'INPUT' ||
        activeElement.tagName === 'TEXTAREA' ||
        activeElement.isContentEditable
    );

    if (isInputFocused) return; // Ne rien faire si on est dans un champ texte

    if (event.key === 'Escape' || event.key === 'Backspace') {
        exit();
    }
});





// Fonction pour afficher un popup permettant de modifier le nom et le salaire d'un grade
function showEditGradeModal(grade,currentJobId) {
    const overlay = document.createElement('div');
    overlay.classList.add('modal-overlay');

    const modal = document.createElement('div');
    modal.classList.add('modal');

    const title = document.createElement('h3');
    title.textContent = `Modifier le grade : ${grade.name}`;

    const form = document.createElement('form');
    form.classList.add('modal-form');

    const nameLabel = document.createElement('label');
    nameLabel.textContent = 'Nom du grade :';
    const nameInput = document.createElement('input');
    nameInput.type = 'text';
    nameInput.value = grade.name;

    const salaryLabel = document.createElement('label');
    salaryLabel.textContent = 'Salaire :';
    const salaryInput = document.createElement('input');
    salaryInput.type = 'number';
    salaryInput.value = grade.payment;

    const buttonsDiv = document.createElement('div');
    buttonsDiv.classList.add('modal-buttons');

    const confirmBtn = document.createElement('button');
    confirmBtn.textContent = 'Confirmer';
    confirmBtn.classList.add('confirm');
    confirmBtn.type = 'button';

    const cancelBtn = document.createElement('button');
    cancelBtn.textContent = 'Annuler';
    cancelBtn.classList.add('cancel');
    cancelBtn.type = 'button';

    confirmBtn.onclick = () => {
        const updatedGrade = {
            jobName: currentJobId,  
            gradeId: grade.grade,     
            name: nameInput.value,
            payment: parseFloat(salaryInput.value),
        };
    
        fetch('https://Pipou-Jobs/editGrade', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(updatedGrade),
        }).then(() => {
            console.log('Grade mis à jour envoyé au script Lua');
        });
    
        document.body.removeChild(overlay);
    };

    cancelBtn.onclick = () => {
        document.body.removeChild(overlay);
    };

    form.appendChild(nameLabel);
    form.appendChild(nameInput);
    form.appendChild(salaryLabel);
    form.appendChild(salaryInput);
    buttonsDiv.appendChild(confirmBtn);
    buttonsDiv.appendChild(cancelBtn);
    modal.appendChild(title);
    modal.appendChild(form);
    modal.appendChild(buttonsDiv);
    overlay.appendChild(modal);
    document.body.appendChild(overlay);
}
