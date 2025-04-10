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

    document.getElementById('actualiser-solde').addEventListener('click', function () {
        updateBanque();
    });
});

let currentJobLabel = null;
let currentJobId = null;

function display(bool, joblabel, jobid) {
    if (bool) {
        document.body.style.display = 'flex';
        document.getElementById("header-job").textContent = joblabel;
        document.getElementById("footer-job-name").textContent = joblabel;
        currentJobLabel = joblabel;
        currentJobId = jobid;
        updateEmployees();
    } else {
        document.body.style.display = 'none';
    }
}

display(false);

function exit() {
    fetch('https://Pipou-Jobs/exit', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

window.addEventListener('message', (event) => {
    const item = event.data;

    if (item.type === 'ui') {
        display(item.status, item.joblabel, item.jobid);
    }

    if (item.type === 'ui:jobinfo') {
        const employeeList = item.listemployee;
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
                showModal(emp.name, currentJobId);
            });
            tbody.appendChild(row);
        });
    }

    if (item.type === 'ui:banqueinfo') {
        document.getElementById('banque-solde').textContent = formatCurrency(item.bankaccount);
    }
});

document.addEventListener('keyup', function (event) {
    if (['INPUT', 'TEXTAREA'].includes(document.activeElement.tagName)) return;
    if (event.key === 'Escape' || event.key === 'Backspace') {
        exit();
    }
});

function updateEmployees() {
    if (!currentJobId) return;
    fetch('https://Pipou-Jobs/getJobInfo', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ JobId: currentJobId })
    });
}

function updateBanque() {
    fetch('https://Pipou-Jobs/getBanqueInfo', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ JobId: currentJobId })
    });
}

function updateGrade() {
    fetch('https://Pipou-Jobs/getGradeInfo', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ JobId: currentJobId })
    })
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
                showEditGradeModal(grade, currentJobId);
            });
            tbody.appendChild(row);
        });
    });
}

function formatCurrency(amount) {
    return amount.toLocaleString('fr-FR', {
        style: 'currency',
        currency: 'EUR'
    });
}

function showModal(fullName, jobid) {
    const overlay = document.createElement('div');
    overlay.className = 'modal-overlay';

    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.innerHTML = `
        <h3>Voulez-vous vraiment licencier ${fullName} ?</h3>
        <div class="modal-buttons">
            <button class="confirm">Confirmer</button>
            <button class="cancel">Annuler</button>
        </div>
    `;

    modal.querySelector('.confirm').addEventListener('click', () => {
        fetch('https://Pipou-Jobs/FireSomeone', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ fullName, jobname: jobid })
        });
        document.body.removeChild(overlay);
    });

    modal.querySelector('.cancel').addEventListener('click', () => {
        document.body.removeChild(overlay);
    });

    overlay.appendChild(modal);
    document.body.appendChild(overlay);
}

function showEditGradeModal(grade, jobId) {
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
            jobName: jobId,
            gradeId: grade.grade,
            name: document.getElementById('grade-name').value,
            payment: parseFloat(document.getElementById('grade-salaire').value),
        };

        fetch('https://Pipou-Jobs/editGrade', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(updatedGrade),
        });
        document.body.removeChild(overlay);
    });

    modal.querySelector('.cancel').addEventListener('click', () => {
        document.body.removeChild(overlay);
    });

    overlay.appendChild(modal);
    document.body.appendChild(overlay);
}
