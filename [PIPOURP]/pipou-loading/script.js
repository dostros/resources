window.onload = function() {
    // Exemple de délai d'attente de 3 secondes avant de retirer l'écran de chargement
    setTimeout(function() {
        // Vous pouvez effectuer un appel à l'event pour cacher l'écran lorsque le chargement est terminé
        // Exemple d'un appel pour signaler au client que le chargement est terminé :
        // Trigger le script client pour masquer l'UI
        fetch(`https://${GetParentResourceName()}/loadingComplete`, {
            method: "POST",
        });

    }, 3000); // Temps d'attente de 3 secondes
};

// Recevoir l'événement de changement d'état de chargement
window.addEventListener('message', function(event) {
    if (event.data.action === 'show') {
        document.body.style.display = 'block';
    } else if (event.data.action === 'hide') {
        document.body.style.display = 'none';
    }
});

window.addEventListener("message", function (event) {
    if (event.data.type === "loadingProgress") {
        let progress = event.data.progress; // Reçu de FiveM (0 à 100)
        document.getElementById("progressBar").style.width = progress + "%";
    }

    if (event.data.type === "loadingComplete") {
        document.getElementById("progressBar").style.width = "100%";
        setTimeout(() => {
            document.querySelector(".progress-container").style.display = "none"; // Cacher la barre après le chargement
        }, 1000);
    }
});
