window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.action === "SHOW_PROGRESSBAR") {
        showProgressbar(data.text, data.duration);
    }
});

let progressbarAllowCancel = true;

function showProgressbar(text, duration, allowCancel = true) {
    progressbarAllowCancel = allowCancel;

    const container = document.getElementById("progressbar-container");
    const fill = document.getElementById("progressbar-fill");
    const textElement = document.getElementById("progressbar-text");

    container.style.display = "block";
    fill.style.transition = `width ${duration}ms linear`;
    fill.style.width = "0%";

    textElement.textContent = `${text}${allowCancel ? " (X pour annuler)" : ""}`;

    void fill.offsetWidth;
    setTimeout(() => fill.style.width = "100%", 10);

    setTimeout(() => {
        container.style.display = "none";
        fill.style.width = "0%";
    }, duration);
}


document.addEventListener('keydown', (e) => {
    if (e.key === 'x' && progressbarAllowCancel) {
        const container = document.getElementById("progressbar-container");
        if (container.style.display === "block") {
            container.style.display = "none";
            $.post(`https://${GetParentResourceName()}/cancelProgressbar`, JSON.stringify({}));
        }
    }
});
