import React, { useState } from 'react';

import './style/Attack.css';

function Attack({ lab, config }) {
  // const [spyLabs, setSpyLabs] = useState(lab.LabInfo.spiedLabs || {
  //   'lab1': {
  //     name: 'Laboratorio Rivale',
  //     labId: 'lab:dfhfhndf43812xfs',
  //     resources: {
  //       'attacker': 100,
  //       'defender': 100,
  //       items: [
  //         {
  //           name: 'item1',
  //           quantity: 100
  //         },
  //         {
  //           name: 'item2',
  //           quantity: 100
  //         }
  //       ],
  //       money: 10000,
  //     },
  //     owner: {
  //       name: 'Ettore Viandante',
  //       identifier: 'steam:1234567890'
  //     },
  //     employees: [
  //       {
  //         name: 'Giuseppe Del Papa',
  //         identifier: 'steam:1234567890',
  //       },
  //       {
  //         name: 'Vic Mackey',
  //         identifier: 'steam:1234567890',
  //       }
  //     ],
  //   },
  //   'lab2': {
  //     name: 'Laboratorio Rivale',
  //     labId: 'lab:dfhfhndf43812xfs',
  //     resources: {
  //       'attacker': 100,
  //       'defender': 100,
  //       items: [
  //         {
  //           name: 'item1',
  //           quantity: 100
  //         },
  //         {
  //           name: 'item2',
  //           quantity: 100
  //         }
  //       ],
  //       money: 10000,
  //     },
  //     owner: {
  //       name: 'Ettore Viandante',
  //       identifier: 'steam:1234567890'
  //     },
  //     // employees: [
  //     //   {
  //     //     name: 'Giuseppe Del Papa',
  //     //     identifier: 'steam:1234567890',
  //     //   },
  //     //   {
  //     //     name: 'Vic Mackey',
  //     //     identifier: 'steam:1234567890',
  //     //   }
  //     // ],
  //   },
  //   'lab3': {
  //     name: 'Laboratorio Rivale',
  //     labId: 'lab:dfhfhndf43812xfs',
  //     resources: {
  //       // 'attacker': 100,
  //       'defender': 100,
  //       items: [
  //         {
  //           name: 'item1',
  //           quantity: 100
  //         },
  //         {
  //           name: 'item2',
  //           quantity: 100
  //         }
  //       ],
  //       money: 10000,
  //     },
  //     owner: {
  //       name: 'Ettore Viandante',
  //       identifier: 'steam:1234567890'
  //     },
  //     employees: [
  //       {
  //         name: 'Giuseppe Del Papa',
  //         identifier: 'steam:1234567890',
  //       },
  //       {
  //         name: 'Vic Mackey',
  //         identifier: 'steam:1234567890',
  //       }
  //     ],
  //   },
  // });

  const [spyLabs, setSpyLabs] = useState(lab.LabInfo.spiedLabs || null);

  const [spyTime, setSpyTime] = useState(lab.LabInfo.spyTime || 0);
  const [attackTime, setAttackTime] = useState(lab.LabInfo.attackTime || 0);

  // const [attackResult, setAttackResult] = useState({
  //   lostAttackers: 0,
  //   resources: {
  //     money: 1500,
  //     items: [],
  //   },
  //   damageDone: 12000,
  // });

  const [attackResult, setAttackResult] = useState(lab.LabInfo.attackResult || null);

  const handleBuySpy = () => {
    // setIsBuyNuiOpen(false);
    fetch('https://KmF_Lab/attack/buySpy', {
      method: 'POST',
      body: JSON.stringify({
        labId: lab.LabId,
      }),
    });
  };

  const closeAttackResult = () => {
    setAttackResult(null);
    fetch('https://KmF_Lab/attack/closeAttackResult', {
      method: 'POST',
      body: JSON.stringify({
        labId: lab.LabId,
      }),
    });
  };

  const hasAllInfo = (lab) => {
    if (spyLabs) {
      if (spyLabs[lab]?.['LabInfo']?.extraInfo?.owner !== 'LIVELLO SPIA NON SUFFICIENTE' && spyLabs[lab]?.['LabInfo']?.extraInfo?.resources.attacker !== 'LIVELLO SPIA NON SUFFICIENTE' && spyLabs[lab]?.['LabInfo']?.extraInfo?.resources.defender !== 'LIVELLO SPIA NON SUFFICIENTE' && spyLabs[lab]?.['LabInfo']?.extraInfo?.resources.money !== 'LIVELLO SPIA NON SUFFICIENTE' && spyLabs[lab]?.['LabInfo']?.extraInfo?.resources.items !== 'LIVELLO SPIA NON SUFFICIENTE') {
        console.log('Hai tutte le informazioni');
        return true;
      }
      console.log('Non hai tutte le informazioni');
      return false;
    }
    console.log('Non hai tutte le informazioni');
    return false;
  }

  return (
    <div className='attack_page'>
      <h2 className="title">Attacca laboratori rivali</h2>
      <div className="attack-container">
        {
          attackResult !== null &&
          <div className="attack-result">
            <span className="attack-results">Riepilogo ultimo attacco</span>
            <span className="attack-results-list">
              <div className="attack-result-item">
                <span className="attack-result-item-title">Danni monetari inflitti</span>
                <span className="attack-result-item-value">${attackResult.damageDone}</span>
              </div>
              <div className="attack-result-item">
                <span className="attack-result-item-title">Materiali ottenuti</span>
                <span className="attack-result-item-value">
                  {
                    attackResult.resources.items.length > 0 ?
                    attackResult.resources.items.map((item, index) => {
                      return (
                        <span className="attack-result-item-value-item" key={index}>{item.name} x{item.quantity}</span>
                      )
                    }) : (
                      <span className="attack-result-item-value-item">Nessun materiale ottenuto</span>
                    )
                  }
                </span>
              </div>
              <div className="attack-result-item">
                <span className="attack-result-item-title">Attaccanti persi</span>
                <span className="attack-result-item-value">{attackResult.lostAttackers}</span>
              </div>
            </span>
            <button className="attack-result-btn" onClick={() => closeAttackResult()}>Chiudi riepilogo</button>
          </div>
        }
        {
          !attackResult &&
          spyLabs !== null ? (
            <>
            {
              <div className="spy-info">
                <span className="spy-info-title">Laboratori spiati</span>
                <div className="spy-labs-list">
                  {
                    Object.keys(spyLabs).map((lab, index) => {
                      return (
                        <div className="spied-lab" key={index}>
                          <span className="spied-lab-name">Laboratorio Rivale</span>
                          <div className="spied-lab-owner">
                            <span className="spied-lab-owner-title">Proprietario</span>
                            <span className="spied-lab-owner-value">{spyLabs[lab]?.['LabInfo']?.extraInfo?.owner || 'Nessuna informazione'}</span>
                          </div>
                          <div className="spied-lab-resources">
                            <span className="spied-lab-resources-title">Risorse</span>
                            <div className="spied-lab-resources-list">
                              <div className="spied-lab-resource">
                                <span className="spied-lab-resource-title">Attaccanti</span>
                                <span className="spied-lab-resource-value">{spyLabs[lab]?.['LabInfo']?.extraInfo?.resources?.attacker || 0}</span>
                              </div>
                              <div className="spied-lab-resource">
                                <span className="spied-lab-resource-title">Difensori</span>
                                <span className="spied-lab-resource-value">{spyLabs[lab]?.['LabInfo']?.extraInfo?.resources?.defender || 0}</span>
                              </div>
                              <div className="spied-lab-resource">
                                <span className="spied-lab-resource-title">Soldi</span>
                                <span className="spied-lab-resource-value">{spyLabs[lab]?.['LabInfo']?.extraInfo?.resources?.money || 0}</span>
                              </div>
                              <div className="spied-lab-resource">
                                <span className="spied-lab-resource-title">Totale magazzino</span>
                                <span className="spied-lab-resource-value">{spyLabs[lab]?.['LabInfo']?.extraInfo?.resources?.items || 0}</span>
                              </div>
                            </div>
                          </div>
                          <div className="spied-lab-actions">
                            <button className="spied-lab-action-btn attack">Attacca</button>
                            <button className={"spied-lab-action-btn " + (hasAllInfo(lab) ? 'disabled' : 'info')}>Ottieni più informazioni</button>
                          </div>
                        </div>
                      )
                    })
                  }
                </div>
              </div>
            }
            </>
          ) : (
            !attackResult &&
            spyTime > 0 ? (
              <div className="spy-time">
                <span className="spy-time-title">La spia è in viaggio e tornerà tra:</span>
                <span className="spy-time-value">{Math.floor(spyTime / 60)} {spyTime > 60 ? 'minuti' : 'minuto'}</span>
              </div>
            ) :
            !attackResult &&
            attackTime > 0 ? (
              <div className="attack-time">
                <span className="attack-time-title">Attacco in corso, tempo rimanente:</span>
                <span className="attack-time-value">{Math.floor(attackTime / 60)} {attackTime > 60 ? 'minuti' : 'minuto'}</span>
              </div>
            ) :
            !attackResult &&
            <div className='no-spy'>
              <span className="no-spy-labs">Nessuna informazione sui laboratori rivali</span>
              <div className="buy-spy">
                <button className="buy-spy-btn" onClick={() => handleBuySpy()}>Assolda una spia - ${config.SpyBaseCost || 0}</button>
              </div>
            </div>
          )
        }
      </div>
    </div>
  );
}

export default Attack;