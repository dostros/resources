$(document).ready(function () {
    // Au démarrage, afficher "index" par défaut
    $('.panel-content').hide();
    $('#index').show();

    $('#menu a').click(function (e) {
        e.preventDefault(); // empêche la redirection

        const page = $(this).attr('href');

        // Cacher tous les contenus
        $('.panel-content').hide();

        // Afficher celui cliqué
        $('#' + page).show();

        switch (page) {
            case 'employees':
                fetch(`https://${GetParentResourceName()}/getemployeelist`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        joblabel: "EMS",
                    }),
                })
                .then((response) => response.json())
                    break;
            default:

        }
    });
});

