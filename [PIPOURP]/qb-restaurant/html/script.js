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

    // Listen for messages from the server to show or hide the UI
    window.addEventListener('message', (event) => {
        var item = event.data;

        // Show or hide the UI based on the message
        if (item.type === 'ui') {
            display(item.status);
        }
    });

    // Close the UI if the player presses escape and backspace
    document.onkeyup = function (data) {
        if (data.which == 27) {
    
            $.post(`https://qb-restaurant/exit`, JSON.stringify({}));
            
            return;
        }
    };
    document.onkeyup = function (data) {
        if (data.which == 8) {
    
            $.post(`https://qb-restaurant/exit`, JSON.stringify({}));
            
            return;
        }
    };

    // Produce food

    let makemargaritabutton = document.getElementById("make-food-margarita");
    makemargaritabutton.addEventListener("click", function () {
        
        
        
        $.post(`https://qb-restaurant/makeMargarita`, JSON.stringify({
            amount: 10
        }));
    });


});
