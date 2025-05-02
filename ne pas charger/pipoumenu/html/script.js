//////////////////////OPEN MENU////////////////////////
document.addEventListener("DOMContentLoaded", function () {
    // Function to display or hide the UI based on a boolean value
    function display(bool) {
        if (bool) {
            $("body").show();
        } else {
            $("body").hide();
            var listjobdiv = document.getElementById("contentsubmenupipou2")
            listjobdiv.innerHTML = "";
        }
    }
    display(false);

    // Listen for messages from the server to show or hide the UI
    window.addEventListener('message', (event) => {
        var item = event.data;
        // Display the UI
        if (item.type === 'ui') {
            display(item.status);
        }
        
        //Create joblistmenu
        if (item.type === 'joblistmenucreate') {

            
            var name = item.name;
            var label = item.label;
                
            var jobdiv = document.createElement("div");
            jobdiv.classList.add("jobchoice");
            jobdiv.classList.add("contentdiv");
            var jobbutton = document.createElement("button");
            jobbutton.textContent = label;
            jobbutton.id = name;
            jobdiv.appendChild(jobbutton);
            document.getElementById("contentsubmenupipou2").appendChild(jobdiv);
            addlistenerjob();
                
        }
    });




    // Close the UI if the player presses escape or backspace
    document.addEventListener('keyup', function (event) {
        if (event.key === 'Escape' || event.key === 'Backspace') {
            numbersticker = 0;
            numbersticker_label.textContent = numbersticker.toString();

            fetch('https://pipoumenu/exit', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({}),
            })
                .then((response) => response.json())
                .then((data) => console.log(data))
                .catch((error) => console.error('Error:', error));
        }
    });
});

////////////////////////////////////////////////////////////////////////////////////////
//                              OPEN / CLOSE SUBMENU
////////////////////////////////////////////////////////////////////////////////////////

// Menus
const mainMenu = document.getElementById('PipouContentMenu1');
const jobMenu = document.getElementById('PipouContentMenu2');
const vehicleMenu = document.getElementById('vehiclecontentmenu');
const modsMenu = document.getElementById('mods_vehiclecontentmenu');

// Show menu function
function showMenu(menuToShow) {
    // Hide all menus
    mainMenu.style.display = 'none';
    jobMenu.style.display = 'none';
    vehicleMenu.style.display = 'none';
    modsMenu.style.display = 'none';

    var listjobdiv = document.getElementById("contentsubmenupipou2")
    listjobdiv.innerHTML = "";

    // Show the selected menu
    menuToShow.style.display = 'flex';
}

// Event listeners for navigation
document.getElementById('job-button').addEventListener('click', () => {
    showMenu(jobMenu);
    fetch('https://pipoumenu/getJobList', {})
});

document.getElementById('vehiclemenu-button').addEventListener('click', () => {
    showMenu(vehicleMenu);
});

document.getElementById('mods_vehiclemenu').addEventListener('click', () => {
    showMenu(modsMenu);
});

// Back buttons
const backButtons = document.querySelectorAll('.backbutton');
backButtons.forEach((button) => {
    button.addEventListener('click', () => {
        showMenu(mainMenu);
    });
});

////////////////////////////////////////////////////////////////////////////////////////
//                                 ATTRIBUTION JOB
////////////////////////////////////////////////////////////////////////////////////////

// Popup for job selection
function showPopup(jobName) {
    const popupContainer = document.getElementById('popupContainer');
    const popupTitle = document.getElementById('popupTitle');
    const popupInput = document.getElementById('popupInput');

    popupTitle.textContent = `Entrez un nombre pour le job ${jobName}`;
    popupInput.value = ''; // Reset input
    popupContainer.style.display = 'flex';

    // Confirm button
    document.getElementById('popupConfirm').onclick = () => {
        const number = popupInput.value.trim();
        if (number && !isNaN(number)) {
            fetch('https://pipoumenu/getjob', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    job: jobName,
                    grade: parseInt(number, 10),
                }),
            })
                .then((response) => response.json())
                .then((data) => console.log(data))
                .catch((error) => console.error('Error:', error));

            popupContainer.style.display = 'none';
        } else {
            alert('Veuillez entrer un nombre valide.');
        }
    };

    // Cancel button
    document.getElementById('popupCancel').onclick = () => {
        popupContainer.style.display = 'none';
    };
}

// Add event listeners to job choice buttons
addlistenerjob();


function addlistenerjob(){
    const jobButtons = document.querySelectorAll('.jobchoice button');
    jobButtons.forEach((button) => {
    button.addEventListener('click', () => {
        const jobName = button.textContent.trim();
        showPopup(jobName);
    });
    });

}

////////////////////////////////////////////////////////////////////////////////////////
//                                MODIFICATIONS VEHICLES
////////////////////////////////////////////////////////////////////////////////////////

// Sticker modification
let numbersticker = 0;
const numbersticker_label = document.getElementById('number_sticker');

const minusSticker = document.getElementById('minus_sticker');
const plusSticker = document.getElementById('plus_sticker');

minusSticker.addEventListener('click', () => {
    numbersticker--;
    numbersticker_label.textContent = numbersticker.toString();

    fetch('https://pipoumenu/change_livery_vehicle', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            numbersticker: numbersticker,
        }),
    })
        .then((response) => response.json())
        .then((data) => console.log(data))
        .catch((error) => console.error('Error:', error));
});

plusSticker.addEventListener('click', () => {
    numbersticker++;
    numbersticker_label.textContent = numbersticker.toString();

    fetch('https://pipoumenu/change_livery_vehicle', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            numbersticker: numbersticker,
        }),
    })
        .then((response) => response.json())
        .then((data) => console.log(data))
        .catch((error) => console.error('Error:', error));
});

// Vehicle spawn popup
const spawnButton = document.getElementById('spawn_vehiclemenu');
spawnButton.addEventListener('click', () => {
    const vehiclePopupContainer = document.getElementById('vehiclePopupContainer');
    vehiclePopupContainer.style.display = 'flex';

    const confirmButton = document.getElementById('vehiclePopupConfirm');
    confirmButton.onclick = () => {
        const selectedModel = document.getElementById('vehicleModelSelect').value;

        fetch('https://pipoumenu/spawn_vehicle', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                model: selectedModel,
            }),
        })
            .then((response) => response.json())
            .then((data) => console.log(data))
            .catch((error) => console.error('Error:', error));

        vehiclePopupContainer.style.display = 'none';
    };

    const cancelButton = document.getElementById('vehiclePopupCancel');
    cancelButton.onclick = () => {
        vehiclePopupContainer.style.display = 'none';
    };
});
