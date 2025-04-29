let selectedIndex = 0;
let menuOptions = [];
let menuIsOpen = false;

window.addEventListener("message", (event) => {
    const data = event.data;

    switch (data.action) {
        case "OPEN_MENU":
            document.getElementById("buttons").innerHTML = "";
            menuIsOpen = true;
            return openMenu(data.options, data.title, data.subtitle);
        case "CLOSE_MENU":
            return closeMenu();
        case "OPEN_INPUT":
            return openInput(data.title, data.subtitle);
        case "OPEN_LIST_MENU":
            document.getElementById("buttons").innerHTML = "";
            menuIsOpen = true;
            openList(data.title, data.subtitle, data.options);
            break;
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
            case "buttonWithDescription":
                html += getButtonWithDescription(option.label, option.data?.description || "", index, index === selectedIndex);
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
    }), function(response) {
        if (response && response.close) {
            closeMenu();
        }
    });
}


const closeMenu = () => {
    $("#buttons").html("");
    $('#imageHover').hide();

    document.getElementById('container').classList.remove("active");
    menuIsOpen = false; // <<< ICI, marquer menu fermé immédiatement

    setTimeout(() => {
        document.getElementById("buttons").innerHTML = "";
        $('#imageHover').hide();
        menuOptions = [];
        selectedIndex = 0;
    }, 300);
}


document.addEventListener('keydown', (e) => {
    if (!menuIsOpen) return;

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
            sendSliderChange(selectedIndex, current.data.value); // << ICI
        }
    }
    else if (menuIsOpen && event.key === "Escape") {
        $.post(`https://${GetParentResourceName()}/closeMenu`, JSON.stringify({}));
        closeMenu();
        menuIsOpen = false;
    }
});

function updateSelection() {
    document.querySelectorAll('.menu-item').forEach((el, i) => {
        el.classList.toggle('active', i === selectedIndex);

        const option = menuOptions[i];
        if (option.type === "slider") {
            const valueElement = el.querySelector('.value');
            if (valueElement) {
                valueElement.textContent = option.data.value; // <-- Mise à jour visuelle du slider
            }
        }
        if (option.type === "checkbox") {
            const headerElement = el.querySelector('.header');
            if (headerElement) {
                headerElement.innerHTML = `${option.label} [${option.data.checked ? '✔' : '✖'}]`; // <-- Mise à jour visuelle de la checkbox aussi
            }
        }
    });
}


function sendSliderChange(index, value) {
    $.post(`https://${GetParentResourceName()}/sliderChange`, JSON.stringify({
        index: index,
        value: value,
    }));
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
            <div class="header">${header}</div>
            <div class="slider-controls">
                <span class="arrow">⬅️</span>
                <span class="value">${value}</span>
                <span class="arrow">➡️</span>
            </div>
        </div>
    `;
}


function getButtonWithDescription(header, description, id, isActive = false) {
    return `
        <div class="menu-item button ${isActive ? "active" : ""}" id="${id}">
            <div class="header">${header}</div>
            <div class="description">${description}</div>
        </div>
    `;
}


const openInput = (title, subtitle) => {
    document.getElementById("container").classList.add("active");


    menuOptions = [];
    selectedIndex = 0;


    // Tu crées dynamiquement ton input ici
    document.getElementById("menu-title").textContent = title;
    document.getElementById("menu-subtitle").textContent = subtitle || "";

    document.getElementById("buttons").innerHTML = `
        <input id="textInput" type="text" class="input-text" placeholder="Votre texte ici...">
        <div class="menu-item button" id="submitInput">Valider</div>
    `;

    document.getElementById("submitInput").addEventListener("click", function() {
        const value = document.getElementById("textInput").value;
        $.post(`https://${GetParentResourceName()}/submitInput`, JSON.stringify({
            text: value
        }));
        closeMenu();
    });
}




const openList = (title, subtitle, list) => {
    document.getElementById("container").classList.add("active");

    menuOptions = list.map((label, index) => ({
        type: "button",
        label: label,
        data: { index: index }
    }));
    selectedIndex = 0;

    document.getElementById("menu-title").textContent = title;
    document.getElementById("menu-subtitle").textContent = subtitle || "";

    let html = "";

    list.forEach((option, index) => {
        html += `
            <div class="menu-item button" id="list_${index}">
                <div class="header">${option}</div>
            </div>
        `;
    });

    document.getElementById("buttons").innerHTML = html;

    // Sélection initiale
    updateSelection();

    list.forEach((_, index) => {
        document.getElementById(`list_${index}`).addEventListener("click", function() {
            $.post(`https://${GetParentResourceName()}/selectListOption`, JSON.stringify({
                index: index
            }));
            closeMenu();
        });
    });
}

