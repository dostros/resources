//Variables --------------------------------------------------------------------------

//Functions---------------------------------------------------------------------------


    

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
    //display(false);

    function exit () {

        display(false)

        fetch('https://d-Pipou-Cloth/exit', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({}),
        })
            .then((response) => response.json())
            .then((data) => console.log(data))
    }

    // Listen for messages from the server to show or hide the UI
    window.addEventListener('message', (event) => {
        var item = event.data;
        // Display the UI
        if (item.type === 'ui') {

            display(item.status,item.garagetype);
        }
    });


    // Close the UI if the player presses escape or backspace
    document.addEventListener('keyup', function (event) {
        if (event.key === 'Escape' || event.key === 'Backspace') {
            exit();
        }
    });

});


function showTab(tabName) {
    const tabs = document.querySelectorAll('.tab-content');
    tabs.forEach(tab => tab.style.display = 'none');
    document.getElementById(`tab-${tabName}`).style.display = 'block';
}

window.addEventListener('message', (event) => {
    var item = event.data;
    if (item.type === 'ui') {
        display(item.status);
        showTab(item.label);
    }
});







