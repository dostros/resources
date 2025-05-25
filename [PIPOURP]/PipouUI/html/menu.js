let selectedIndex = 0;
let menuOptions = [];
let menuIsOpen = false;
let menuHistory = [];
let isInputOpen = false;
let currentTabs = null;
let activeTabIndex = 0;
let currentPosition = "menu-top-right";
let visibleItems = [];



const buttonsContainer = document.getElementById("buttons");
const container = document.getElementById("container");
const menuTitle = document.getElementById("menu-title");
const menuSubtitle = document.getElementById("menu-subtitle");

buttonsContainer.addEventListener('click', (event) => {
    if (!menuIsOpen) return;
    if (event.target.closest('.slider-bar')) return;

    const target = event.target.closest('.menu-item');
    if (!target) return;

    const id = target.id;
    if (id.startsWith('list_')) {
        const index = parseInt(id.replace('list_', ''), 10);
        $.post(`https://${GetParentResourceName()}/selectListOption`, JSON.stringify({ index }));
        closeMenu();
    } else {
        const index = parseInt(id);
        if (!isNaN(index)) {
            sendSelectOption(index);
        }
    }
});


window.addEventListener("message", (event) => {
    const data = event.data;

    switch (data.action) {
        case "OPEN_MENU":
            closeMenu(true);
            setTimeout(() => {
                menuIsOpen = true;
                setMenuPosition(data.position);
                openMenu(data.options, data.title, data.subtitle, false, null, 0, data.position);
            }, 50);
            break;
        case "CLOSE_MENU":
            return closeMenu();
        case "OPEN_INPUT":
            return openInput(data.title, data.subtitle);
        case "OPEN_LIST_MENU":
            closeMenu(true);
            setTimeout(() => {
                menuIsOpen = true;
                openList(data.title, data.subtitle, data.options);
            }, 50);
            break;
        case "OPEN_TAB_MENU":
            closeMenu(true);
            setTimeout(() => {
                menuIsOpen = true;
                renderTabs(data.tabs, 0);
                openMenu(data.tabs[0].options, data.tabs[0].label, data.subtitle, false, data.tabs, 0, data.position);
                
            }, 50);
            break;
            

        default:
            return;
    }
});

const openMenu = (options, title, subtitle, fromHistory = false, tabs = null, activeTab = 0, position = "menu-top-right") => {
    setMenuPosition(position);

    if (menuIsOpen && !fromHistory && !tabs) {
        menuHistory.push({
            options: menuOptions,
            title: menuTitle.textContent,
            subtitle: menuSubtitle.textContent,
            selectedIndex: selectedIndex,
            position: currentPosition
        });
    }

    menuOptions = options;
    selectedIndex = 0;
    menuTitle.textContent = title;
    menuSubtitle.textContent = subtitle || "";


    // Générer les boutons HTML
    const buttonsHTML = options.map((opt, idx) => {
        switch (opt.type) {
            case "checkbox":
                return getCheckboxRender(opt.label, idx, opt.checked);
            case "slider":
                return getSliderRender(opt.label, idx, opt.value, opt.min, opt.max);
            case "section":
                return getSectionRender(opt.label, idx);
            case "searchinput":
                return getSearchInputRender(opt.placeholder || "🔍 Rechercher...", idx, idx === selectedIndex);
            case "clothslider":
                return getClothSliderRender(opt.label, idx, opt.drawable, opt.texture, opt.drawableMin, opt.drawableMax, opt.textureMax);
                            
            default:
                return getButtonRender(opt.label, idx);
        }
    }).join("");

    // Injecter dans le DOM
    buttonsContainer.innerHTML = buttonsHTML;
    refreshVisibleItems();


    container.classList.add("active");
    menuIsOpen = true;

    if (tabs) {
        currentTabs = tabs;
        activeTabIndex = activeTab;
        renderTabs(tabs, activeTab);
    } else {
        currentTabs = null;
        document.getElementById("menu-tabs").innerHTML = "";
    }

    updateSelection();
};


function sendSelectOption(index) {
    $.post(`https://${GetParentResourceName()}/selectOption`, JSON.stringify({
        index: index,
    }), function (response) {
        if (response && response.close) {
            closeMenu();
        }
    });
}

const closeMenu = (quick = false) => {
    container.classList.remove("active");
    menuIsOpen = false;
    menuHistory = [];

    const reset = () => {
        buttonsContainer.innerHTML = "";
        $('#imageHover').hide();
        menuOptions = [];
        selectedIndex = 0;
        menuHistory = [];
        isInputOpen = false;
    };
    if (quick) reset();
    else setTimeout(reset, 300);
};




document.addEventListener('keydown', (e) => {
    if (!menuIsOpen) return;

    switch(e.key) {
        case 'ArrowDown':
            if (!menuIsOpen || isInputOpen || visibleItems.length === 0) break;
            playSound('navigate');

            selectedIndex = (selectedIndex + 1) % visibleItems.length;
            updateSelection();
            break;

        case 'ArrowUp':
            if (!menuIsOpen || isInputOpen || visibleItems.length === 0) break;
            playSound('navigate');

            selectedIndex = (selectedIndex - 1 + visibleItems.length) % visibleItems.length;
            updateSelection();
            break;

        case 'Enter':
            playSound('select');
            handleMenuEnter();
            break;

        case 'ArrowRight':
            if (isSliderSelected()) {
                playSound('navigate');
                handleSliderChange(1);
            } else if (currentTabs && activeTabIndex < currentTabs.length - 1) {
                playSound('navigate');
                activeTabIndex++;
                openMenu(currentTabs[activeTabIndex].options, currentTabs[activeTabIndex].label, menuSubtitle.textContent, false, currentTabs, activeTabIndex);
            }
            break;

        case 'ArrowLeft':
            if (isSliderSelected()) {
                playSound('navigate');
                handleSliderChange(-1);
            } else if (currentTabs && activeTabIndex > 0) {
                playSound('navigate');
                activeTabIndex--;
                openMenu(currentTabs[activeTabIndex].options, currentTabs[activeTabIndex].label, menuSubtitle.textContent, false, currentTabs, activeTabIndex);
            }
            break;

        case 'Backspace':
            if (document.activeElement?.closest('.menu-search-input')) break;            
        case 'Escape':
            playSound('back');
            if (menuHistory.length > 0) {
                const lastMenu = menuHistory.pop();
                if (lastMenu && lastMenu.options && lastMenu.options.length > 0) {
                    openMenu(lastMenu.options, lastMenu.title, lastMenu.subtitle, true, null, 0, lastMenu.position || "menu-top-right");
                    selectedIndex = lastMenu.selectedIndex || 0;
                    updateSelection();
                }
            } else {
                fetch(`https://${GetParentResourceName()}/pipou_back`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({})
                });
            }
            break;
    }
});



function updateSelection() {
    if (!visibleItems.length) return;

    visibleItems.forEach((el, i) => {
        const isSelected = i === selectedIndex;

        if (isSelected && !el.classList.contains('active')) {
            el.classList.add('active');
        } else if (!isSelected && el.classList.contains('active')) {
            el.classList.remove('active');
        }

        const idx = el && el.id ? getIndexFromElementId(el.id) : null;
        const option = idx !== null ? menuOptions[idx] : null;
        if (!option) return;

        if (option.type === "slider") {
            const valueEl = el.querySelector('.value');
            if (valueEl) valueEl.textContent = option.value;

            const percent = ((option.value - option.min) / (option.max - option.min)) * 100;
            const fill = el.querySelector('.slider-fill');
            if (fill) fill.style.width = `${percent}%`;
        }

        if (option.type === "checkbox") {
            const header = el.querySelector('.header');
            if (header) {
                header.textContent = `${option.label} [${option.checked ? '✔' : '✖'}]`;
            }
        }
        
    });

    const activeElement = visibleItems[selectedIndex];
    if (activeElement) {
        scrollToActiveItem(activeElement);
    }
}

function scrollToActiveItem(activeElement) {
    const offsetTop = activeElement.offsetTop;
    const offsetBottom = offsetTop + activeElement.offsetHeight;
    const scrollTop = buttonsContainer.scrollTop;
    const containerHeight = buttonsContainer.clientHeight;

    const margin = 50;
    const headerHeight = menuTitle.offsetHeight + menuSubtitle.offsetHeight + 20;

    if (offsetTop < scrollTop + margin + headerHeight) {
        buttonsContainer.scrollTo({ top: offsetTop - headerHeight - margin, behavior: 'smooth' });
    } else if (offsetBottom > scrollTop + containerHeight - margin) {
        buttonsContainer.scrollTo({ top: offsetBottom - containerHeight + margin, behavior: 'smooth' });
    }
}

function getIndexFromElementId(id) {
    if (!id || typeof id !== "string") return null;
    const match = id.match(/^item-(\d+)|^list_(\d+)$/);
    return match ? parseInt(match[1] || match[2], 10) : null;
}



function refreshVisibleItems() {
    visibleItems = Array.from(document.querySelectorAll('.menu-item')).filter(el => el.style.display !== 'none');
}


function sendSliderChange(index, value) {
    $.post(`https://${GetParentResourceName()}/sliderChange`, JSON.stringify({
        index: index,
        value: value,
    }));
}


function getButtonRender(header, id, isActive = false) {
    return `
        <div class="menu-item button ${isActive ? "active" : ""}" id="item-${id}">
            <div class="header">${header}</div>
        </div>
    `;
}

function getCheckboxRender(header, id, checked, isActive = false) {
    return `
        <div class="menu-item checkbox ${isActive ? "active" : ""}" id="item-${id}">
            <div class="header">${header} [${checked ? '✔' : '✖'}]</div>
        </div>
    `;
}


function getSliderRender(header, id, value, min, max, isActive = false) {
    const percentage = ((value - min) / (max - min)) * 100;

    return `
        <div class="menu-item slider ${isActive ? "active" : ""}" id="item-${id}">
            <div class="header">${header} : <span class="value">${value}</span></div>
            <div class="slider-bar" data-index="${id}">
                <div class="slider-fill" style="width: ${percentage}%;"></div>
            </div>
            <div class="slider-minmax"><span>${min}</span><span>${max}</span></div>
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
    refreshVisibleItems();

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
    refreshVisibleItems();
    updateSelection();
}

function handleMenuEnter() {
    const logicalIndex = getLogicalIndexFromVisible(selectedIndex);
    const current = menuOptions[logicalIndex];
    if (!current) return;

    if (current.type === "checkbox") {
        current.checked = !current.checked;
        updateSelection();
        sendSelectOption(logicalIndex);

    } else if (current.type === "slider") {
        sendSelectOption(logicalIndex);

    } else if (current.type === "searchinput") {
        const input = document.querySelector(`#item-${logicalIndex} input`);
        if (!input) return;

        if (input.disabled) {
            input.disabled = false;
            input.focus();
            isInputOpen = true;

            input.removeEventListener("input", input._searchListener);

            input._searchListener = () => {
                const filter = input.value.toLowerCase();
                document.querySelectorAll(".menu-item").forEach(item => {
                    if (item.classList.contains("searchinput")) return;
                    const label = item.querySelector(".header")?.innerText.toLowerCase() || "";
                    const desc = item.querySelector(".description")?.innerText.toLowerCase() || "";
                    item.style.display = (label.includes(filter) || desc.includes(filter)) ? "flex" : "none";
                });
            
                // Force mise à jour des items visibles et re-sélectionne un élément valide
                refreshVisibleItems();
                selectedIndex = 0;
                updateSelection();
            };
            

            input.addEventListener("input", input._searchListener);
        } else {
            input.disabled = true;
            input.blur();
            isInputOpen = false;
        }

        $.post(`https://${GetParentResourceName()}/setKeyboardFocus`, JSON.stringify({ focus: !input.disabled }));
        return;

    } else {
        sendSelectOption(logicalIndex);
    }
}




function handleSliderChange(direction) {
    const logicalIndex = getLogicalIndexFromVisible(selectedIndex);
    const current = menuOptions[logicalIndex];
    if (current && current.type === "slider" && typeof current.value === "number") {
        const step = current.step || 1;
        current.value = Math.min(Math.max(current.value + direction * step, current.min), current.max);
        updateSelection();
        sendSliderChange(logicalIndex, current.value);
    }
}


function playSound(name) {
    $.post(`https://${GetParentResourceName()}/playSound`, JSON.stringify({
        name: name
    }));
}

buttonsContainer.addEventListener('wheel', (e) => {
    buttonsContainer.scrollTop += e.deltaY;
});

function getSectionRender(header, id) {
    return `
        <div class="menu-item section" id="${id}">
            <div class="header">${header}</div>
        </div>
    `;
}

function renderTabs(tabs, activeIndex = 0) {
    const tabContainer = document.getElementById("menu-tabs");
    tabContainer.innerHTML = "";

    tabs.forEach((tab, index) => {
        const btn = document.createElement("button");
        btn.className = "tab-button" + (index === activeIndex ? " active" : "");
        btn.textContent = tab.label || `Onglet ${index + 1}`;

        btn.addEventListener("click", () => {
            openMenu(tab.options, tab.label, "", false, tabs, index);
        });

        tabContainer.appendChild(btn);
    });
}

function isSliderSelected() {
    const logicalIndex = getLogicalIndexFromVisible(selectedIndex);
    const current = menuOptions[logicalIndex];
    return current && current.type === "slider";
}


const setMenuPosition = (position) => {
    container.classList.remove(
        "menu-top-left",
        "menu-top-right",
        "menu-bottom-left",
        "menu-bottom-right",
        "menu-center"
    );
    if (position) {
        container.classList.add(position);
        currentPosition = position;
    }
};

buttonsContainer.addEventListener("click", (e) => {
    const bar = e.target.closest(".slider-bar");
    if (!bar || !menuIsOpen) return;

    const index = parseInt(bar.getAttribute("data-index"));
    const option = menuOptions[index];
    if (!option || option.type !== "slider") return;

    const rect = bar.getBoundingClientRect();
    const clickX = e.clientX - rect.left;
    const ratio = clickX / rect.width;
    const value = Math.round(option.min + ratio * (option.max - option.min));

    option.value = Math.min(Math.max(value, option.min), option.max);
    updateSelection();
    sendSliderChange(index, option.value);
});


buttonsContainer.addEventListener("dblclick", (e) => {
    const bar = e.target.closest(".slider-bar");
    if (!bar || !menuIsOpen) return;

    const index = parseInt(bar.getAttribute("data-index"));
    const option = menuOptions[index];
    if (!option || option.type !== "slider") return;

    // Ouvrir le menu input
    $.post(`https://${GetParentResourceName()}/OpenInputMenu`, JSON.stringify({
        title: "Saisir une valeur",
        subtitle: `Entre ${option.min} et ${option.max}`
    }));

    // Définir le listener une seule fois
    const inputListener = function(evt) {
        if (evt.data?.action === "inputSubmitted") {
            window.removeEventListener("message", inputListener);

            const raw = evt.data.value;
            const num = Number(raw);
            if (!isNaN(num)) {
                option.value = Math.min(Math.max(num, option.min), option.max);
                updateSelection();
                sendSliderChange(index, option.value);
            }
        }
    };

    window.addEventListener("message", inputListener);
});

function getSearchInputRender(placeholder, id, isActive = false) {
    return `
        <div class="menu-item searchinput ${isActive ? "active" : ""}" id="item-${id}">
            <input type="text" class="menu-search-input" placeholder="${placeholder}" disabled />
        </div>
    `;
}


function getNextVisibleIndex(start, direction) {
    if (!visibleItems.length) return start;
    return (start + direction + visibleItems.length) % visibleItems.length;
}

function getLogicalIndexFromVisible(index) {
    if (!visibleItems[index]) return null;
    const el = visibleItems[index];
    return getIndexFromElementId(el?.id);
}


function getClothSliderRender(label, id, drawable, texture, drawableMin, drawableMax, textureMax, isActive = false) {
    const drawPercent = ((drawable - drawableMin) / (drawableMax - drawableMin)) * 100;
    const texPercent = ((texture) / (textureMax)) * 100;

    return `
        <div class="menu-item clothslider ${isActive ? "active" : ""}" id="item-${id}">
            <div class="header">${label}</div>
            <div class="clothslider-group">
                <div class="clothslider-line">
                    <span>Modèle</span>
                    <div class="slider-bar" data-index="${id}" data-type="draw">
                        <div class="slider-fill" style="width: ${drawPercent}%"></div>
                    </div>
                    <span class="value">${drawable}</span>
                </div>
                <div class="clothslider-line">
                    <span>Texture</span>
                    <div class="slider-bar" data-index="${id}" data-type="tex">
                        <div class="slider-fill" style="width: ${texPercent}%"></div>
                    </div>
                    <span class="value">${texture}</span>
                </div>
            </div>
        </div>
    `;
}

buttonsContainer.addEventListener("input", (e) => {
    if (!menuIsOpen) return;

    const drawableInput = e.target.closest(".clothslider-drawable");
    const textureInput = e.target.closest(".clothslider-texture");

    if (drawableInput) {
        const index = parseInt(drawableInput.dataset.index, 10);
        const value = parseInt(drawableInput.value, 10);
        const option = menuOptions[index];
        if (option && option.type === "clothslider") {
            option.drawable = value;
            option.texture = 0; // reset texture
            sendClothSliderChange(index, option.drawable, option.texture);
            openMenu(menuOptions, menuTitle.textContent, menuSubtitle.textContent, true, currentTabs, activeTabIndex, currentPosition);
        }
    } else if (textureInput) {
        const index = parseInt(textureInput.dataset.index, 10);
        const value = parseInt(textureInput.value, 10);
        const option = menuOptions[index];
        if (option && option.type === "clothslider") {
            option.texture = value;
            sendClothSliderChange(index, option.drawable, option.texture);
        }
    }
});


function sendClothSliderChange(index, drawable, texture) {
    $.post(`https://${GetParentResourceName()}/clothsliderChange`, JSON.stringify({
        index,
        drawable,
        texture
    }));
}