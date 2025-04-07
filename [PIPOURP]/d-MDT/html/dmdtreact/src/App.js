import logo from './logo.svg';
import './App.css';
import NavMenu from './Pages/NavMenu/NavMenu';
import Header from './Pages/Header/Header';
import Home from './Pages/Home/Home';
import Case from './Pages/Case/Case';
import Laws from './Pages/Laws/Laws';
import {
  BrowserRouter as Router,
  Routes,
  Route,
} from "react-router-dom";

function App() {
  return (
    <Router>
      <div className="App">
        {/* <header className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <p>
            Edit <code>src/App.js</code> and save to reload.
          </p>
          <a
            className="App-link"
            href="https://reactjs.org"
            target="_blank"
            rel="noopener noreferrer"
          >
            Learn React
          </a>
        </header> */}
        <Header/>
        <div id="ContentDiv">
          < NavMenu/>



          <Routes>
          <Route path="/Home" element={<Home/>} />
          <Route path="/Case" element={<Case/>} />
          <Route path="/Laws" element={<Laws/>}/>
        </Routes>
        </div>
          
      </div>
    </Router>
  
  );
}

export default App;
