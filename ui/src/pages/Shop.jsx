import React from 'react'

import { useState, useEffect } from 'react'
import { useNui, callNui } from "../hooks/FiveM.js"

import './style/Shop.css'

function Shop(props) {

  const [labs, setLabs] = useState(props.config.LabList);
  const [boughtLabs, setBoughtLabs] = useState(props.lab.BoughtLabs || {});

  const [upgrades, setUpgrades] = useState(props.config.UpgradesList);
  const [boughtUpgrades, setBoughtUpgrades] = useState(props.lab.BoughtUpgrades);

  useEffect(() => {
    setBoughtLabs(props.lab.BoughtLabs);
    setBoughtUpgrades(props.lab.BoughtUpgrades);
  }, [props.lab]);

  return (
    <div className='shop_page'>
      <h2 className="title">Shop</h2>
      <div className="shop_container">
        <div className="shop_lab">
          {/* <h3>Lab</h3> */}
          <h3 className="buy_lab_title">
            Acquista laboratori
          </h3>
          
          <div className="laboratories">
          { labs && 
            Object.keys(labs).map((key, index) => {
              return (
                <Lab
                  key={index}
                  id={key}
                  img={labs[key].img}
                  title={labs[key].title}
                  description={labs[key].description}
                  price={labs[key].price}
                  boughtLabs={boughtLabs}
                />
              )
            })
          }
          </div>
        
        </div>
        <div class="divider"></div>
        <div className="shop_upgrade">
          <h3 className="buy_lab_title">
            Acquista potenziamenti
          </h3>

          <div className="upgrades">
          { upgrades && 
            Object.keys(upgrades).map((key, index) => {
              return (
                <Upgrade
                  key={index}
                  title={upgrades[key].title}
                  description={upgrades[key].description}
                  price={upgrades[key].price}
                  id={key}
                  boughtUpgrades={boughtUpgrades}
                  config={props.config}
                />
              )
            })
          }
          </div>
        </div>
      </div>
    </div>
  )
}

function Lab(props) {

  let found = false;

  const buyLab = () => {
    callNui('buyLabUpgrade', {
      type: 'lab',
      id: props.id,
    });
  }

  return (
    <>
      {props.boughtLabs && Object.keys(props.boughtLabs).length > 0 ? (
        <>
          {Object.keys(props.boughtLabs).map((key, index) => {
            // console.log('key', key);
            // console.log('props.id', props.id);

            if (key === props.id) {
              found = true;
            }
          })}
          { !found ? (
            <div className="lab" key={props.id}>
              <img src={props.img} alt={props.title} />
              <h3>{props.title}</h3>
              <p>{props.description}</p>
              <div className="lab_price">
                <p>${props.price}</p>
                <button className="employee-button promote" 
                  onClick={buyLab}
                >Compra</button>
              </div>
            </div>
          ) : (
            <div className="lab" key={props.id}>
              <img src={props.img} alt={props.title} />
              <h3>{props.title}</h3>
              <p>{props.description}</p>
              <div className="lab_price">
                <p>${props.price}</p>
                <button className="employee-button promote disabled" 
                >Acquistato</button>
              </div>
            </div>
          )}
        </>
      ) : (
        <div className="lab" key={props.id}>
          <img src={props.img} alt={props.title} />
          <h3>{props.title}</h3>
          <p>{props.description}</p>
          <div className="lab_price">
            <p>${props.price}</p>
            <button className="employee-button promote" onClick={buyLab}>Compra</button>
          </div>
        </div>
      )}
    </>
  );
}

function Upgrade(props) {

  const buyLab = () => {
    callNui('buyLabUpgrade', {
      type: 'upgrade',
      id: props.id,
    });
  }

  return (
    <>
      <div className="upgrade" key={props.id}>
        <div className='upgrade_top'>
          <h3>{props.title}</h3>
          <span>Livello:
            <span className='upgrade_level'>{props.boughtUpgrades[props.id].level}</span>
          </span>
        </div>
        <p>{props.description}</p>
        <div className="upgrade_price">
          {
            !props.boughtUpgrades[props.id].disabled &&
            props.boughtUpgrades[props.id].level > 0 &&
            <p>${Math.floor(props.price * Math.pow(props.config.UpgradesList[props.id].price_multiplier, props.boughtUpgrades[props.id].level))}</p>
          }
          {
            props.boughtUpgrades[props.id].level === 0 &&
            <p>{props.boughtUpgrades[props.id].disabled ? 'Non disponibile' : 
              props.boughtUpgrades[props.id].level === props.boughtUpgrades[props.id].max_level ? 'Completo' :
            '$' + props.price}</p>
          }
          {
            props.boughtUpgrades[props.id].max_level &&
            props.boughtUpgrades[props.id].max_level === props.boughtUpgrades[props.id].level ?
              <button className="employee-button promote disabled">Max</button> :
              !props.boughtUpgrades[props.id].disabled ?
              <button className="employee-button promote" onClick={buyLab}>Compra</button> :
              <button className="employee-button promote disabled">BLOCCATO</button>
          }
          {
            !props.boughtUpgrades[props.id].max_level && !props.boughtUpgrades[props.id].disabled &&
            <button className="employee-button promote" onClick={buyLab}>Compra</button>
          }
        </div>
      </div>
    </>
  );
}

export default Shop

