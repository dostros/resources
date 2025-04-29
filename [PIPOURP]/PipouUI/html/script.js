let selectedIndex = 0;
let menuOptions = [];
let menuIsOpen = false;
let menuHistory = [];
let isInputOpen = false;

const buttonsContainer = document.getElementById("buttons");
const container = document.getElementById("container");
const menuTitle = document.getElementById("menu-title");
const menuSubtitle = document.getElementById("menu-subtitle");


buttonsContainer.addEventListener('click', (event) => {
    if (!menuIsOpen) return;
    const target = event.target.closest('.menu-item');
    if (!target) return;
    
    const id = target.id;
    if (id.startsWith('list_')) {
        const index = parseInt(id.replace('list_', ''), 10);
        $.post(`https://${GetParentResourceName()}/selectListOption`, JSON.stringify({index}));
        closeMenu();
    }
});


window.addEventListener("message", (event) => {
    const data = event.data;

    switch (data.action) {
        case "OPEN_MENU":
            buttonsContainer.innerHTML = "";
            menuIsOpen = true;
            return openMenu(data.options, data.title, data.subtitle);
        case "CLOSE_MENU":
            return closeMenu();
        case "OPEN_INPUT":
            return openInput(data.title, data.subtitle);
        case "OPEN_LIST_MENU":
            buttonsContainer.innerHTML = "";
            menuIsOpen = true;
            openList(data.title, data.subtitle, data.options);
            break;
        default:
            return;
    }
});


const openMenu = (options, title, subtitle, fromHistory = false) => {
    if (menuIsOpen && !fromHistory) {
        menuHistory.push({
            options: menuOptions,
            title: menuTitle.textContent,
            subtitle: menuSubtitle.textContent,
            selectedIndex: selectedIndex
        });
    }

    menuOptions = options;
    selectedIndex = 0;

    menuTitle.textContent = title;
    menuSubtitle.textContent = subtitle || "";


    buttonsContainer.innerHTML = options.map((opt, idx) => {
        switch(opt.type) {
            case "checkbox":
                return getCheckboxRender(opt.label, idx, opt.checked, idx === selectedIndex);
            case "slider":
                return getSliderRender(opt.label, idx, opt.value, opt.min, opt.max, idx === selectedIndex);
            default:
                return getButtonRender(opt.label, idx, idx === selectedIndex);
        }
    }).join("");

    container.classList.add("active");
    menuIsOpen = true;
    updateSelection();
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
    container.classList.remove("active");
    menuIsOpen = false;
    setTimeout(() => {
        buttonsContainer.innerHTML = "";
        $('#imageHover').hide();
        menuOptions = [];
        selectedIndex = 0;
        menuHistory = [];
        isInputOpen = false;
    }, 300);
};



document.addEventListener('keydown', (e) => {
    if (!menuIsOpen || isInputOpen) return;

    switch(e.key) {
        case 'ArrowDown':
            playSound('navigate');
            selectedIndex = (selectedIndex + 1) % menuOptions.length;
            updateSelection();
            break;

        case 'ArrowUp':
            playSound('navigate');
            selectedIndex = (selectedIndex - 1 + menuOptions.length) % menuOptions.length;
            updateSelection();
            break;

        case 'Enter':
            playSound('select');
            handleMenuEnter();
            break;

        case 'ArrowLeft':
        case 'ArrowRight':
            playSound('navigate');
            handleSliderChange(e.key === 'ArrowLeft' ? -1 : 1);
            break;

        case 'Escape':
        case 'Backspace':
            playSound('back');
            if (menuHistory.length > 0) {
                const lastMenu = menuHistory.pop();
                if (lastMenu && lastMenu.options && lastMenu.options.length > 0) {
                    openMenu(lastMenu.options, lastMenu.title, lastMenu.subtitle, true); // <= true important
                    selectedIndex = lastMenu.selectedIndex || 0;
                    updateSelection();
                } else {
                    $.post(`https://${GetParentResourceName()}/closeMenu`, JSON.stringify({}));
                    closeMenu();
                }
            } else {
                $.post(`https://${GetParentResourceName()}/closeMenu`, JSON.stringify({}));
                closeMenu();
            }
        break;
    }
});



function updateSelection() {
    document.querySelectorAll('.menu-item').forEach((el, i) => {
        el.classList.toggle('active', i === selectedIndex);
        const option = menuOptions[i];
        if (!option) return;

        if (option.type === "slider") {
            el.querySelector('.value').textContent = option.value;
        }
        if (option.type === "checkbox") {
            el.querySelector('.header').textContent = `${option.label} [${option.checked ? '✔' : '✖'}]`;
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
    container.classList.add("active");


    menuOptions = [];
    selectedIndex = 0;
    isInputOpen = true;


    // Tu crées dynamiquement ton input ici
    menuTitle.textContent = title;
    menuSubtitle.textContent = subtitle || "";

    buttonsContainer.innerHTML = `
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
    container.classList.add("active");

    menuOptions = list.map((label, index) => ({
        type: "button",
        label: label,
        data: { index: index }
    }));
    selectedIndex = 0;

    menuTitle.textContent = title;
    menuSubtitle.textContent = subtitle || "";

    let html = "";

    list.forEach((option, index) => {
        html += `
            <div class="menu-item button" id="list_${index}">
                <div class="header">${option}</div>
            </div>
        `;
    });

    buttonsContainer.innerHTML = html;

    updateSelection();
}

function handleMenuEnter() {
    const current = menuOptions[selectedIndex];
    if (!current) return;

    if (current.type === "checkbox") {
        current.checked = !current.checked;
        updateSelection();
        sendSelectOption(selectedIndex);
    } else if (current.type === "button") {
        sendSelectOption(selectedIndex);
    }
}

function handleSliderChange(direction) {
    const current = menuOptions[selectedIndex];
    if (current && current.type === "slider" && typeof current.value === "number") {
        const step = current.step || 1;
        current.value = Math.min(Math.max(current.value + direction * step, current.min), current.max);
        updateSelection();
        sendSliderChange(selectedIndex, current.value);
    }
}


function playSound(name) {
    $.post(`https://${GetParentResourceName()}/playSound`, JSON.stringify({
        name: name
    }));
}
