let selectedIndex = 0;
let menuOptions = [];

window.addEventListener("message", (event) => {
    const data = event.data;

    switch (data.action) {
        case "OPEN_MENU":
            return openMenu(data.options, data.title, data.subtitle);
        case "CLOSE_MENU":
            return closeMenu();
        default:
            return;
    }
});

function getButtonRender(header, id, isActive = false) {
    return `
        <div class="menu-item button ${isActive ? "active" : ""}" id="${id}">
            <div class="header">${header}</div>
        </div>
    `;
}

const openMenu = (options = [], title = "", subtitle = "") => {
    console.log("📦 Menu reçu :", { title, subtitle, options });

    menuOptions = options;
    selectedIndex = 0;

    // Séparer le titre et le sous-titre en dehors du HTML injecté
    document.getElementById("menu-title").textContent = title;
    document.getElementById("menu-subtitle").textContent = subtitle || "";

    let html = "";

    options.forEach((option, index) => {
        switch (option.type) {
            case "checkbox":
                html += getCheckboxRender(option.label, index, option.data?.checked, index === selectedIndex);
                break;
            case "slider":
                html += getSliderRender(option.label, index, option.data?.value, option.data?.min, option.data?.max, index === selectedIndex);
                break;
            default:
                html += getButtonRender(option.label, index, index === selectedIndex);
        }
    });

    document.getElementById("buttons").innerHTML = html;
    document.getElementById("container").classList.add("active");

    $(".menu-item").click(function () {
        const targetId = $(this).attr("id");
        sendSelectOption(parseInt(targetId));
    });
};


function sendSelectOption(index) {
    $.post(`https://${GetParentResourceName()}/selectOption`, JSON.stringify({
        index: index,
    }));
    closeMenu();
}

const closeMenu = () => {
    $("#buttons").html("");
    $('#imageHover').hide();
    document.getElementById('container').classList.remove("active");

    menuOptions = [];
    selectedIndex = 0;
};

document.addEventListener('keydown', (e) => {
    if (menuOptions.length === 0) return;

    const key = e.key;

    if (key === 'ArrowDown') {
        selectedIndex = (selectedIndex + 1) % menuOptions.length;
        updateSelection();
    } else if (key === 'ArrowUp') {
        selectedIndex = (selectedIndex - 1 + menuOptions.length) % menuOptions.length;
        updateSelection();
    } else if (key === 'Enter') {
        const current = menuOptions[selectedIndex];
        if (current.type === "checkbox") {
            current.data.checked = !current.data.checked;
            updateSelection();
            sendSelectOption(selectedIndex);
        } else if (current.type === "slider") {
            // Pas avec Enter mais avec ← →
        } else {
            sendSelectOption(selectedIndex);
        }
    } else if (key === 'ArrowLeft' || key === 'ArrowRight') {
        const current = menuOptions[selectedIndex];
        if (current.type === "slider") {
            const step = current.data.step || 1;
            if (key === 'ArrowLeft') current.data.value = Math.max(current.data.min, current.data.value - step);
            if (key === 'ArrowRight') current.data.value = Math.min(current.data.max, current.data.value + step);
            updateSelection();
        }
    } else if (key === 'Escape') {
        $.post(`https://${GetParentResourceName()}/closeMenu`);
        closeMenu();
    }
});

function updateSelection() {
    document.querySelectorAll('.menu-item').forEach((el, i) => {
        el.classList.toggle('active', i === selectedIndex);
    });
}


function getButtonRender(header, id, isActive = false) {
    return `
        <div class="menu-item button ${isActive ? "active" : ""}" id="${id}">
            <div class="header">${header}</div>
        </div>
    `;
}

function getCheckboxRender(header, id, checked, isActive = false) {
    return `
        <div class="menu-item checkbox ${isActive ? "active" : ""}" id="${id}">
            <div class="header">${header} [${checked ? '✔' : '✖'}]</div>
        </div>
    `;
}

function getSliderRender(header, id, value, min, max, isActive = false) {
    return `
        <div class="menu-item slider ${isActive ? "active" : ""}" id="${id}">
            <div class="header">${header}: ${value}</div>
        </div>
    `;
}
