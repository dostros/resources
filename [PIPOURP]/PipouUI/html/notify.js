window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.action === "SHOW_NOTIFICATION") {
        showNotification(data.message, data.type, data.duration);
    }
});

function showNotification(message, type = "info", duration = 3000) {
    const container = document.getElementById("notification-container");
    
    if (container.children.length >= 4) {
        container.removeChild(container.firstChild);
    }

    const notif = document.createElement("div");
    notif.className = `notification ${type}`;
    notif.textContent = message;

    container.appendChild(notif);

    setTimeout(() => {
        notif.classList.add('exiting');
        setTimeout(() => notif.remove(), 500);
    }, duration);
}
