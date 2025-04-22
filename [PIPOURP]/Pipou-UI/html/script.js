let selectedIndex = 0;
let menuOptions = [];

window.addEventListener("message", (event) => {
    const data = event.data;

    switch (data.action) {
        case "OPEN_MENU":
            return openMenu(data.options); // ✅ data.options => tableau d'options
        case "CLOSE_MENU":
            return closeMenu();
        default:
            return;
    }
});

const getButtonRender = (header, message = "", id, isMenuHeader = false, isDisabled = false, icon = "") => {
    return `
        <div class="${isMenuHeader ? "title" : "button"} ${isDisabled ? "disabled" : ""}" id="${id}">
            <div class="icon">
                ${icon.startsWith("fa") ? `<i class="${icon}"></i>` : icon.endsWith(".png") || icon.endsWith(".jpg") ? `<img src="${icon}" width="30px" onerror="this.remove();">` : ""}
            </div>
            <div class="column">
                <div class="header">${header}</div>
                ${message ? `<div class="text">${message}</div>` : ""}
            </div>
        </div>
    `;
};





const openMenu = (options = []) => {
    let html = "";
    options.forEach((option, index) => {
        html += getButtonRender(option.label, index);
    });

    document.getElementById("buttons").innerHTML = html;
    document.getElementById("container").classList.add("active");

    $(".button").click(function () {
        const targetId = $(this).attr("id");
        $.post(`https://${GetParentResourceName()}/clickedButton`, JSON.stringify(parseInt(targetId)));
    });
};



const closeMenu = () => {
    $("#buttons").html("");
    $('#imageHover').hide();
    const container = document.getElementById('container');
    container.classList.remove("active"); // ❌ Cacher le conteneur

    buttonParams = [];
    images = [];
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
        $.post(`https://${GetParentResourceName()}/selectOption`, JSON.stringify({
            index: selectedIndex,
        }));
        
        closeMenu();
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
