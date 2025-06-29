$(document).ready(function () {
    // Affichage par défaut
    $('.panel-content').hide();
    $('#index').show();
    $('#menu a[href="index"]').addClass('active');

    // Gestion des clics sur le menu
    $('#menu a').click(function (e) {
        e.preventDefault();
        const page = $(this).attr('href');

        $('.panel-content').hide();
        $('#' + page).show();

        $('#menu a').removeClass('active');
        $(this).addClass('active');

        if (page === 'patients') {
            fetch(`https://${GetParentResourceName()}/getpatientslist`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ joblabel: "EMS" }),
            })
            .then((response) => response.json())
            .then((data) => {
                const list = $('#patientsList');
                list.empty();

                data.forEach((patient) => {
                    const row = $(`<tr>
                        <td>${patient.id}</td>
                        <td>${patient.nom}</td>
                        <td>${patient.prenom}</td>
                        <td>${patient.age}</td>
                        <td>${patient.maladie}</td>
                    </tr>`);

                    row.on('click', function () {
                        $('#edit_id').val(patient.id);
                        $('#edit_nom').val(patient.nom);
                        $('#edit_prenom').val(patient.prenom);
                        $('#edit_age').val(patient.age);
                        $('#edit_sexe').val(patient.sexe);
                        $('#edit_maladie').val(patient.maladie);
                        $('#edit_remarques').val(patient.remarques);
                        $('#patientProfileModal').fadeIn();
                    });

                    list.append(row);
                });
            });
        }
    });

    // Gérer l'ouverture/fermeture de la modale
    $('#openModal').on('click', () => $('#modalOverlay').fadeIn());
    $('#cancelModal').on('click', () => $('#modalOverlay').fadeOut());

    // Nouveau patient
    $('#patientForm').on('submit', function (e) {
        e.preventDefault();

        const data = {
            nom: $('#nom').val(),
            prenom: $('#prenom').val(),
            age: parseInt($('#age').val()),
            sexe: $('#sexe').val(),
            maladie: $('#maladie').val(),
            remarques: $('#remarques').val()
        };

        fetch(`https://${GetParentResourceName()}/addPatient`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data),
        }).then(() => {
            $('#modalOverlay').fadeOut();
            $('#patientForm')[0].reset();
            $('#menu a[href="patients"]').trigger('click');
        });
    });
});

// Affichage / Masquage NUI
document.addEventListener("DOMContentLoaded", function () {
    function display(bool) {
        if (bool) {
            $("body").show();
        } else {
            $("body").hide();
        }
    }

    display(false);

    $('.modal-overlay').hide();

    function exit() {
        fetch(`https://${GetParentResourceName()}/exit`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({}),
        }).then((response) => response.json());
    }

    window.addEventListener('message', (event) => {
        const item = event.data;
        if (item.type === 'ui') {
            display(item.status);
        }
    });

    // Écoute globale (hors message) pour éviter duplication
    document.addEventListener('keyup', function (event) {
        if (event.key === 'Escape') {
            exit();
        }
    });
});

$('#closeProfileModal').on('click', function () {
    $('#patientProfileModal').fadeOut(200);
});