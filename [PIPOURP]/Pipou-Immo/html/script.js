// VARIABLES GLOBALES

HouseDoorCoords    = ''
GarageDoorCoords   = ''
GarageOutCoords    = ''

//FONCTION




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
        
    
        display(false)

        fetch('https://Pipou-Immo/exit', {
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
            display(item.status);
        }

        // Display the properties
        if (item.type === 'setPropertyCoords') {


            switch (item.propertyId) {
                case 'button-inputsetupHouseDoor':
                    HouseDoorCoords = item.coords

                    var labelinputsetupHouseDoor = document.getElementById('label-inputsetupHouseDoor')
                    labelinputsetupHouseDoor.innerHTML = '✅'

                    break;
                case 'button-inputsetupGarageDoor':
                    GarageDoorCoords = item.coords

                    var labelinputsetupGarageDoor = document.getElementById('label-inputsetupGarageDoor')
                    labelinputsetupGarageDoor.innerHTML = '✅'
                    break;
                case 'button-inputsetupGarageOut':
                    GarageOutCoords = item.coords

                    var labelinputsetupGarageOut = document.getElementById('label-inputsetupGarageOut')
                    labelinputsetupGarageOut.innerHTML = '✅'
                    break;
                default:
                    break;
            }



        }
    });

    // Close the UI if the player presses escape or backspace
    document.addEventListener('keyup', function (event) {
        if (event.key === 'Escape' || event.key === 'Backspace') {
            exit();
        }
    });

    const PropertiesListbutton = document.getElementById('showProperties');
    PropertiesListbutton.addEventListener('click', function () {

        var properties = document.getElementById('properties');
        properties.style.display = 'block';
    
        var menu = document.getElementById('menu');
        menu.style.display = 'none';
    });

    const closebutton = document.getElementById('close');
    closebutton.addEventListener('click', function () {
        exit();
        
    });

    const sellPropertybutton = document.getElementById('sellProperty');
    sellPropertybutton.addEventListener('click', function () {
        var sellProperty = document.getElementById('sellPropertyForm');
        sellProperty.style.display = 'block';
    
        var menu = document.getElementById('menu');
        menu.style.display = 'none';
    });

    const backbuttons = document.querySelectorAll('.backbutton');
    backbuttons.forEach(function (backbutton) {
        backbutton.addEventListener('click', function () {
            var properties = document.getElementById('properties');
            properties.style.display = 'none';
            var sellProperty = document.getElementById('sellPropertyForm');
            sellProperty.style.display = 'none';

            var menu = document.getElementById('menu');
            menu.style.display = 'block';
        });
    });

    const setpropertybuttons = document.querySelectorAll('.setpropertycoords')
    setpropertybuttons.forEach(function (setpropertybutton) {

        setpropertybutton.addEventListener('click', function () {
            var propertyId = setpropertybutton.getAttribute('id');
            exit()

            
            fetch('https://Pipou-Immo/Pipou-Immo-setPropertyCoords', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({propertyId: propertyId}),
            })
            .then((response) => response.json())
            .then((data) => {})
            .catch((error) => {
                console.error('Erreur lors de la requête :', error);
            });

        });
    });



    //CONFIRMATION BUTTON
    const confirmbutton = document.getElementById('confirmCreationofProperty');

    confirmbutton.addEventListener('click', function () {

        // Display a custom confirmation UI before proceeding
        var confirmationBox = document.getElementById('confirmationBox');
        confirmationBox.style.display = 'block';

        var confirmYes = document.getElementById('confirmYes');
        var confirmNo = document.getElementById('confirmNo');

        confirmYes.addEventListener('click', function () {
            confirmationBox.style.display = 'none';
            proceedWithPropertyCreation();
        });

        confirmNo.addEventListener('click', function () {
            confirmationBox.style.display = 'none';
        });

        function proceedWithPropertyCreation() {
            // Continue with the property creation process
            var propertyName = document.getElementById('propertyName').value;
            var coords1 = HouseDoorCoords;
            var coords2 = GarageDoorCoords;
            var coords3 = GarageOutCoords;
            var typeinterior = document.getElementById('interiorType').value;
            var level = document.getElementById('levelproperty').value;

            // console.log(coords1);
            // console.log(coords2);
            // console.log(coords3);
            // console.log(typeinterior);
            // console.log(level);
            // console.log(propertyName);
            // console.log('test');


            fetch('https://Pipou-Immo/Pipou-Immo-createProperty', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    propertyName: propertyName,
                    coords1: coords1,
                    coords2: coords2,
                    coords3: coords3,
                    typeinterior: typeinterior,
                    level: level
                }),
            })
                .then((response) => response.json())
                .then((data) => console.log(data))
                .catch((error) => console.error('Error:', error));

        }


    });

    
});







