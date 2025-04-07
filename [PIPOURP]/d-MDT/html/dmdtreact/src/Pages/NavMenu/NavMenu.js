import React from 'react';
import './NavMenu.css';
import { Link } from 'react-router-dom';


function NavMenu () {

    return (
        <div id="NavBarMenu">
            <ul>
                <li><Link to="/Home">Home</Link></li>
                <li><Link to="/Case">Casier Judiciaire</Link></li>
                <li><Link tp="/Laws">Lois</Link></li>
            </ul>



        </div>




    )


}

export default NavMenu;