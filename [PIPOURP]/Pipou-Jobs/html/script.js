document.addEventListener("DOMContentLoaded", function () {
    const tabs = document.querySelectorAll(".tab-button");
    const panels = document.querySelectorAll(".tab-panel");

    tabs.forEach(tab => {
        tab.addEventListener("click", function () {
            const target = this.getAttribute("data-target");

            tabs.forEach(t => t.classList.remove("active"));
            panels.forEach(p => p.classList.remove("active"));

            this.classList.add("active");
            document.getElementById(target).classList.add("active");

            if (target === "employes") updateEmployees();
            if (target === "banque") updateBanque();
            if (target === "grade") updateGrade();
        });
    });

    document.querySelector(".tab-button.active").click();

    document.getElementById('actualiser-solde').addEventListener('click', updateBanque);
});

let currentJobLabel = null;
let currentJobId = null;

function display(show, joblabel, jobid) {
    document.body.style.display = show ? 'flex' : 'none';
    if (show) {
        currentJobLabel = joblabel;
        currentJobId = jobid;
        document.getElementById("header-job").textContent = joblabel;
        document.getElementById("footer-job-name").textContent = joblabel;
        updateEmployees();
    }
}

display(false);

function exit() {
    postData('exit');
}

window.addEventListener('message', (event) => {
    const item = event.data;

    switch (item.type) {
        case 'ui':
            display(item.status, item.joblabel, item.jobid);
            break;
        case 'ui:jobinfo':
            renderEmployees(item.listemployee);
            break;
        case 'ui:banqueinfo':
            document.getElementById('banque-solde').textContent = formatCurrency(item.bankaccount);
            break;
    }
});

document.addEventListener('keyup', function (event) {
    if (['INPUT', 'TEXTAREA'].includes(document.activeElement.tagName)) return;
    if (event.key === 'Escape' || event.key === 'Backspace') {
        exit();
    }
});

// ========== FETCH UTILS ==========
function postData(endpoint, data = {}) {
    return fetch(`https://Pipou-Jobs/${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    });
}

// ========== EMPLOYES ==========
function updateEmployees() {
    if (!currentJobId) return;
    postData('getJobInfo', { JobId: currentJobId });
}

function renderEmployees(employeeList) {
    const tbody = document.querySelector('#employes table tbody');
    tbody.innerHTML = '';

    employeeList.forEach(emp => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${emp.name}</td>
            <td>${emp.grade_name}</td>
            <td><button><i class="fas fa-user-slash"></i> Licencier</button></td>
        `;
        row.querySelector('button').addEventListener('click', () => {
            showModal(`Voulez-vous vraiment licencier ${emp.name} ?`, () => {
                postData('FireSomeone', {
                    fullName: emp.name,
                    jobname: currentJobId
                });
            });
        });
        tbody.appendChild(row);
    });
}

// ========== BANQUE ==========
function updateBanque() {
    postData('getBanqueInfo', { JobId: currentJobId });
}

// ========== GRADES ==========
function updateGrade() {
    postData('getGradeInfo', { JobId: currentJobId })
        .then(res => res.json())
        .then(data => {
            const tbody = document.querySelector('#grade table tbody');
            tbody.innerHTML = '';

            data.grades.forEach(grade => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${grade.name}</td>
                    <td>${grade.payment} $</td>
                    <td><button><i class="fas fa-pen"></i> Modifier</button></td>
                `;
                row.querySelector('button').addEventListener('click', () => {
                    showEditGradeModal(grade);
                });
                tbody.appendChild(row);
            });
        });
}

// ========== MODALES ==========
function showModal(message, onConfirm) {
    const overlay = document.createElement('div');
    overlay.className = 'modal-overlay';

    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.innerHTML = `
        <h3>${message}</h3>
        <div class="modal-buttons">
            <button class="confirm">Confirmer</button>
            <button class="cancel">Annuler</button>
        </div>
    `;

    modal.querySelector('.confirm').addEventListener('click', () => {
        onConfirm();
        document.body.removeChild(overlay);
    });

    modal.querySelector('.cancel').addEventListener('click', () => {
        document.body.removeChild(overlay);
    });

    overlay.appendChild(modal);
    document.body.appendChild(overlay);
}

function showEditGradeModal(grade) {
    const overlay = document.createElement('div');
    overlay.className = 'modal-overlay';

    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.innerHTML = `
        <h3>Modifier le grade : ${grade.name}</h3>
        <form class="modal-form">
            <label>Nom du grade :</label>
            <input type="text" value="${grade.name}" id="grade-name">
            <label>Salaire :</label>
            <input type="number" value="${grade.payment}" id="grade-salaire">
        </form>
        <div class="modal-buttons">
            <button class="confirm">Confirmer</button>
            <button class="cancel">Annuler</button>
        </div>
    `;

    modal.querySelector('.confirm').addEventListener('click', () => {
        const updatedGrade = {
            jobName: currentJobId,
            gradeId: grade.grade,
            name: document.getElementById('grade-name').value,
            payment: parseFloat(document.getElementById('grade-salaire').value),
        };

        postData('editGrade', updatedGrade);
        document.body.removeChild(overlay);
    });

    modal.querySelector('.cancel').addEventListener('click', () => {
        document.body.removeChild(overlay);
    });

    overlay.appendChild(modal);
    document.body.appendChild(overlay);
}

// ========== FORMAT ==========
function formatCurrency(amount) {
    return amount.toLocaleString('fr-FR', {
        style: 'currency',
        currency: 'EUR'
    });
}
