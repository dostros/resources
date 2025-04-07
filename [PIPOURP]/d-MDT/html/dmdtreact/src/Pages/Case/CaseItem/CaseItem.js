import React, { useState } from "react";
import ReactQuill from "react-quill";
import "react-quill/dist/quill.snow.css"; // Styles de Quill.js
import './Caseitem.css';



function CaseItem () {

    const [content, setContent] = useState("");


    return(
        <div className='ItemCase'>
                <h1>Rapport n°711</h1>
                <ReactQuill theme="snow" value={content} onChange={setContent} />
        </div>
    )

}

export default CaseItem;
