import React  from "react";
import CaseItem from './CaseItem/CaseItem'
import './Case.css';



function Case () {

    return(
        <div className="CenterContent" id="EditReport">
            <h1 id="titleRepportList">Liste des Rapports</h1>
            <div id="RepportList">
                <CaseItem/>
                <CaseItem/>
                <CaseItem/>
                <CaseItem/>
                <CaseItem/>
                <CaseItem/>
                <CaseItem/>
                <CaseItem/>
                <CaseItem/>
            </div>
        </div>
    )

}

export default Case;
