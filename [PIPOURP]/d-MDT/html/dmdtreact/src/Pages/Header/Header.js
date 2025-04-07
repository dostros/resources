import React from 'react';
import './Header.css';
import logo from '../../logo.svg'


function Header () {
    
    return(
        <div id="AppHeader">
            William Farley
            <img src={logo} alt="logo" />
        </div>
    )

}

export default Header;
