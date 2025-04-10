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

        fetch('https://d-MDT/exit', {
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

       
    });

    // Close the UI if the player presses escape or backspace
    document.addEventListener('keyup', function (event) {
        if (event.key === 'Escape' || event.key === 'Backspace') {
            exit();
        }
    });



    const buttonmdtlspd = document.getElementById('buttonLSPD-MDT');
    buttonmdtlspd.addEventListener('click', function () {
        const LSPDMDT = document.getElementById('LSPD-MDT');
        LSPDMDT.style.display = 'block';
        const buttonscreentablet = document.getElementById('buttonscreentablet');
        buttonscreentablet.style.display = 'none';
    });

    const playbutton = document.getElementById('playbutton');
    playbutton.addEventListener('click', function () {
        const LSPDMDT = document.getElementById('LSPD-MDT');
        LSPDMDT.style.display = 'none';
        const buttonscreentablet = document.getElementById('buttonscreentablet');
        buttonscreentablet.style.display = 'block';
    });

    

});








