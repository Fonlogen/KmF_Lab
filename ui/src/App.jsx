import { useEffect, useRef, useState } from "react";
import "./App.css";

import { useNui, callNui } from "./hooks/FiveM.js";

import Home         from "./pages/Home";
import Shop         from "./pages/Shop";
import Crafting     from "./pages/Crafting";
import Deposit      from "./pages/Deposit";
import Attack       from "./pages/Attack";
import Account      from "./pages/Account";
// import Chest        from "./pages/Chest";
import SideBar      from "./components/SideBar";

import backgroundImg from "../assets/images/labbackground.png";

import clickSound from "../assets/sounds/click.mp3";

const App = () => {

  const [myIdentifier, setMyIdentifier] = useState(null); // This will be set by the NUI callback

  const [fullscreen, setFullscreen] = useState(false); // Toggle fullscreen

  const [showUi, setShowUi] = useState(false); // Toggle visibility
  const [buyLabDialog, showBuyLabDialog] = useState(false);

  const [lab, setLab] = useState({
    LabInfo: {
      "test": "test2",
      "test2": "test3",
      "test3": "test4",
      "test4": "test5",
      "test5": "test6",
      "test6": "test7",
      "test7": "test8",
      "test8": "test9",
      "test9": "test10",
      "test10": "test11",
      "test11": "test12",
      "test12": "test13",
    },
    Employees: {
      ['steam:123456789']: {
        Grade: 0,
        GradeLabel: 'CEO',
        Name: 'Giuseppe Del Papa',
      },
      ['steam:123456781']: {
        Grade: 0,
        GradeLabel: 'CEO',
        Name: 'Giuseppe Del Papa',
      },
      ['steam:123156781']: {
        Grade: 0,
        GradeLabel: 'CEO',
        Name: 'Giuseppe Del Papa',
      },
    },
    Deposit: {
      ['special_carbine_mk2']: {
        count: 10,
        label: 'Special Carbine Mk2',
        price: 1000,
        name: 'special_carbine_mk2',
      }
    },
    Crafting: {
      Tables: {
        locked: true,
        ready: false,
        time: 0,
      },
      Recipes: {
        
      }
    },
  });

  const [config, setConfig] = useState({

  });

  const [myGrade, setMyGrade] = useState([
    {
      grade: 3,
      gradelabel: "CEO"
    }
  ]);
  
  const [page, setPage] = useState("home");

  const switchPage = (pg) => {
    setPage(pg);
  }

  useEffect(() => {
    useNui('showUi', (data) => {
      
      setShowUi(data.toggle);
      setMyIdentifier(data.myIdentifier);
      setLab(data.lab);
      setConfig(data.config);
    });

    useNui('showBuyDialog', (data) => {
      // console.log('showBuyDialog, data: ' + JSON.stringify(data.toggle));
      showBuyLabDialog(data.toggle);
      setConfig(data.config);
    });

    useNui('setLab', (data) => {
      let jsonlab = JSON.stringify(data);
      // console.log('setLab, data: ' + JSON.stringify(data));
      setLab(data.lab);
    });

  }, []);  

  const audioRef = useRef(null);
  const audioRef2 = useRef(null);

  useEffect(() => {
    audioRef.current = new Audio(clickSound);
    audioRef.current.volume = 0.5;

    window.addEventListener('keydown', (event) => {
      if (event.key === 'Escape') {
        showBuyLabDialog(false);
        callNui('closeMenu');
      }
    });
  }, []);

  const playSound = () => {
    audioRef.current.play();
  }

  const playSound2 = () => {
    audioRef2.current.play();
  }

  const toggleFullscreen = () => {
    setFullscreen(!fullscreen);
  }

  return (
    <>
    {
      buyLabDialog &&
      <div className="buylab_dialog">
        <audio ref={audioRef2} src={clickSound} />
        <div className="title">
        <h1>Acquista un laboratorio</h1>
        </div>
        <div className="buylab_dialog_content">
          <div className='dialog_content_header'>
            <p style={{ fontSize: '20px', textAlign: 'left', fontWeight: '800', width: '100%'}}>
              Vuoi acquistare il laboratorio per <span style={{color: 'lime'}}>${config.LabPrice || 100000}</span> sporchi?
            </p>
            <p style={{color: 'lightgrey', fontSize: '14px'}}>
              Acquistando un laboratorio avrai accesso a business esclusivi, un magazzino e le aree di lavoro.
              
            </p>
          </div>
          <div className="buylab_dialog_buttons">
            <button className='buy' onClick={() => {showBuyLabDialog(false); playSound2(); callNui('buyLab', { buy: true });}}>Acquista</button>
            <button className='cancel' onClick={() => {showBuyLabDialog(false); playSound2(); callNui('buyLab', { buy: false });}}>Annulla</button>
          </div>
        </div>
      </div>
    }
    {
      showUi &&
      <>
      <img className='container-bg' src={backgroundImg} style={{width: fullscreen ? '100%' : '1366px', height: fullscreen ? '100%' : '760px'}}/>
      <div className="container" style={{width: fullscreen ? '100%' : '1366px', height: fullscreen ? '100%' : '760px'}}>
        <audio ref={audioRef} src={clickSound} />
        <SideBar switchPage={switchPage} activePage={page} playSound={playSound} toggleFullscreen={toggleFullscreen} />
        {
          page == 'home' &&
            <Home clickSound={playSound} lab={lab} myIdentifier={myIdentifier}/>
        }
        {
          page == 'shop' &&
            <Shop clickSound={playSound} lab={lab} config={config}/>
        }
        {
          page == 'crafting' &&
            <Crafting clickSound={playSound} lab={lab} config={config} />
        }
        {
          page == 'deposit' &&
            <Deposit clickSound={playSound} lab={lab} config={config} />
        }
        {
          page == 'account' &&
            <Account clickSound={playSound} lab={lab} config={config} />
        }
        {/* {
          page == 'chest' &&
            <Chest clickSound={playSound} lab={lab} config={config} />
        } */}
        {
          page == 'attack' &&
            <Attack clickSound={playSound} lab={lab} config={config} />
        }
      </div>
      </>
    }
    </>
  );
};

export default App;
