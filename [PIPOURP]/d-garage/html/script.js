//Variables --------------------------------------------------------------------------

garageopen = ''
garagejob =""
//Functions---------------------------------------------------------------------------

function GetGarageList (label,garagejob ) {

    let div = document.getElementById('GarageMenu__content_actual');
    div.innerHTML = "";
    // let div2 = document.getElementById('GarageMenu__content_other');
    // div2.innerHTML = "";
    // let div3 = document.getElementById('GarageMenu__content_outside');
    // div3.innerHTML = "";
    
    if (!(garagejob)) {
        garagejob = 'nojob'
    }

    
    fetch('https://d-garage/getGarageList', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            label: label,
            garagejob: garagejob
        }),
    })
        .then((response) => response.json())
        .then((data) => console.log(data))
        .catch((error) => console.error('Error:', error));
}

function GetOtherList (label, garagejob) {
    let div2 = document.getElementById('GarageMenu__content_other');
    div2.innerHTML = "";

    fetch('https://d-garage/getOtherList', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            label: label,
            garagejob: garagejob
        }),
    })
        .then((response) => response.json())
        .then((data) => console.log(data))
        .catch((error) => console.error('Error:', error));
}   



function GetOutsideList (label, garagejob) {
    let div3 = document.getElementById('GarageMenu__content_outside');
    div3.innerHTML = "";

    fetch('https://d-garage/getOutsideList', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            label: label,
            garagejob: garagejob}),
    })
        .then((response) => response.json())
        .then((data) => console.log(data))
        .catch((error) => console.error('Error:', error));
}   


function updateselectedlisterners (currentgarage) {
    let buttonsselect = document.querySelectorAll('.GarageMenu__button');

    buttonsselect.forEach(button => {
        button.addEventListener('click', function () {
            
            buttonsselect.forEach(btn => btn.classList.remove('selected'));
            button.classList.add('selected');

            let vehicleDiv = event.target.closest(".vehicle");
            currentmodel = vehicleDiv.querySelector("h3:nth-of-type(1)").innerText;
            currentplate = vehicleDiv.querySelector("h3:nth-of-type(2)").innerText;
            actualgarage = currentgarage;

            fetch('https://d-garage/d_previsualisation', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    model: currentmodel,
                    plate: currentplate,
                    currentgarage: currentgarage
                }),
            })
                .then((response) => response.json())
                .then((data) => console.log(data))
                .catch((error) => console.error('Error:', error));

        })
    })
}

function updateselectedlisternersforOutside () {
    let buttonsselect = document.querySelectorAll('.GarageMenu__button_outside');

    buttonsselect.forEach(button => {
        button.addEventListener('click', function () {
            
            buttonsselect.forEach(btn => btn.classList.remove('selected'));
            button.classList.add('selected');

            let vehicleDiv = event.target.closest(".vehicle");
            currentplate = vehicleDiv.querySelector("h3:nth-of-type(2)").innerText;
            console.log("plaque désirée: " + currentplate)
        })
    })

    let confirmationbutton = document.getElementById('confirmationbutton')

    confirmationbutton.addEventListener('click', function(){
        fetch('https://d-garage/client_set_gps_outside', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                plate: currentplate,
            }),
        })
            .then((response) => response.json())
            // .then((data) => console.log(data))
            .catch((error) => console.error('Error:', error));



    })

}    
    

//------------------------------------------------------------------------------------


document.addEventListener("DOMContentLoaded", function () {
    // Function to display or hide the UI based on a boolean value
    function display(bool) {

        if (bool) {
            $("body").show();
        } else {
            $("body").hide();
        }
    }
    display(false);

    function exit () {
        let div = document.getElementById('GarageMenu__content_actual');
        div.innerHTML = "";
        let div2 = document.getElementById('GarageMenu__content_other');
        div2.innerHTML = "";
        let div3 = document.getElementById('GarageMenu__content_outside');
        div3.innerHTML = "";

        currentmodel = "";
        currentplate = "";
        actualgarage = "";

        choiceselect.forEach(button => {
                choiceselect.forEach(btn => btn.classList.remove('selectedchoice'));
                let startbutton = document.getElementById('garagelist')
                startbutton.classList.add('selectedchoice');
                outsidebutton.style.display ='none';
                othergarage.style.display ="none"
                garagebutton.style.display ='block';
                GetGarageList (garageopen, garagejob)
    
        })
    


        display(false)

        fetch('https://d-garage/exit', {
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

    // Listen for messages from the server to show or hide the UI
    window.addEventListener('message', (event) => {
        var item = event.data;
        // Display the UI
        if (item.type === 'ui') {
            garageopen = item.label
            garagejob = item.garagejob
            display(item.status);
            GetGarageList (garageopen, garagejob);

        }

        if (item.type === 'addVehicleonlist') {
            let vehiclemodel = item.model;
            let vehicleplate = item.plate;
            let divvehicle = document.createElement('div');
            divvehicle.className = 'vehicle';
            let firsttitle = document.createElement('h2');
            firsttitle.innerHTML = "Modèle";
            let firstcontent = document.createElement('h3');
            firstcontent.innerHTML = vehiclemodel;
            let secondtitle = document.createElement('h2');
            secondtitle.innerHTML = "Plaque";
            let secondcontent = document.createElement('h3');
            secondcontent.innerHTML = vehicleplate;
            let button = document.createElement('button');
            button.innerHTML = "Sélectionner";
            button.className = "GarageMenu__button";
            
            let garage = document.getElementById('GarageMenu__content_actual');

            divvehicle.appendChild(firsttitle);
            divvehicle.appendChild(firstcontent);
            divvehicle.appendChild(secondtitle);
            divvehicle.appendChild(secondcontent);
            divvehicle.appendChild(button);
            garage.appendChild(divvehicle);

        }

        if (item.type ==='addOtherVehicleonlist') {
            let vehiclemodel = item.model;
            let vehicleplate = item.plate;
            let vehiclegarage = item.garage


            let divvehicle = document.createElement('div');
            divvehicle.className = 'vehicle';
            
            let firsttitle = document.createElement('h2');
            firsttitle.innerHTML = "Modèle";
            let firstcontent = document.createElement('h3');
            firstcontent.innerHTML = vehiclemodel;
            
            let secondtitle = document.createElement('h2');
            secondtitle.innerHTML = "Plaque";
            let secondcontent = document.createElement('h3');
            secondcontent.innerHTML = vehicleplate;

            let thirdtitle = document.createElement('h2');
            thirdtitle.innerHTML = "Garage";
            let thirdcontent = document.createElement('h3');
            thirdcontent.innerHTML = vehiclegarage;

            let garage = document.getElementById('GarageMenu__content_other');

            divvehicle.appendChild(firsttitle);
            divvehicle.appendChild(firstcontent);
            divvehicle.appendChild(secondtitle);
            divvehicle.appendChild(secondcontent);
            divvehicle.appendChild(thirdtitle);
            divvehicle.appendChild(thirdcontent);
            garage.appendChild(divvehicle);
        }

        if (item.type ==='addOutsideVehicleonlist') {
            let vehiclemodel = item.model;
            let vehicleplate = item.plate;
            
            let jsonString = item.coords.toString()
            let jsonObject = JSON.parse(jsonString);
            let vehiclecoords = `${jsonObject.x}, ${jsonObject.y}, ${jsonObject.z}`;

            let divvehicle = document.createElement('div');
            divvehicle.className = 'vehicle';
            
            let firsttitle = document.createElement('h2');
            firsttitle.innerHTML = "Modèle";
            let firstcontent = document.createElement('h3');
            firstcontent.innerHTML = vehiclemodel;
            
            let secondtitle = document.createElement('h2');
            secondtitle.innerHTML = "Plaque";
            let secondcontent = document.createElement('h3');
            secondcontent.innerHTML = vehicleplate;

            let thirdtitle = document.createElement('h2');
            thirdtitle.innerHTML = "Position";
            let thirdcontent = document.createElement('h3');
            thirdcontent.innerHTML = vehiclecoords;
            let button = document.createElement('button');
            button.innerHTML = "Sélectionner";
            button.className = "GarageMenu__button_outside";

            let garage = document.getElementById('GarageMenu__content_outside');

            divvehicle.appendChild(firsttitle);
            divvehicle.appendChild(firstcontent);
            divvehicle.appendChild(secondtitle);
            divvehicle.appendChild(secondcontent);
            divvehicle.appendChild(thirdtitle);
            divvehicle.appendChild(thirdcontent);
            divvehicle.appendChild(button);
            garage.appendChild(divvehicle);

            updateselectedlisternersforOutside();
        }

        if (item.type === 'updatelistener') {
            updateselectedlisterners(item.currentgarage);
        }

    });


    // Close the UI if the player presses escape or backspace
    document.addEventListener('keyup', function (event) {
        if (event.key === 'Escape' || event.key === 'Backspace') {
            exit();
        }
    });

    // Choisir l'onglet

    let garagebutton = document.getElementById('listactualgarage')
    let othergarage = document.getElementById('othergarage')
    let outsidebutton = document.getElementById('listoutgarage')


    let choiceselect = document.querySelectorAll('.choicelistbutton');

    choiceselect.forEach(button => {
        button.addEventListener('click', function () {
            
            choiceselect.forEach(btn => btn.classList.remove('selectedchoice'));
            button.classList.add('selectedchoice');

            if (button.id === 'garagelist') {
                outsidebutton.style.display ='none';
                othergarage.style.display ="none"
                garagebutton.style.display ='block';
                GetGarageList (garageopen,garagejob)
            }
            else if (button.id ==="othergaragelist")
            {
                outsidebutton.style.display ='none';
                othergarage.style.display ="block"
                garagebutton.style.display ='none';
                GetOtherList(garageopen,garagejob);
            } 
            else if (button.id === 'outlist') {
                outsidebutton.style.display ='block';
                othergarage.style.display ="none"
                garagebutton.style.display ='none';
                GetOutsideList(garageopen, garagejob);
            }
        })
    })

    // Spawn a vehicle
    let spawnbutton = document.getElementById('spawnbutton');

    spawnbutton.addEventListener('click', function () {
        let model = currentmodel
        let plate = currentplate
        let currentgarage = actualgarage.toString();

        if  (model !== "" || plate !== "" || currentgarage !== "") {

            fetch('https://d-garage/d-spawnVehicle', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    model: model,
                    plate: plate,
                    currentgarage: currentgarage
                }),
            })
                .then((response) => response.json())
                .then((data) => console.log(data))
                .catch((error) => console.error('Error:', error)
            );
            exit();
            currentmodel = "";
            currentplate = "";
            actualgarage = "";
        }
    });
});








