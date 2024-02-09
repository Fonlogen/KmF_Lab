import React from 'react'

import { useState, useEffect } from 'react'

import TranslateStr from '../utils/Translator.js'

import { useNui, callNui } from '../hooks/FiveM.js'

import './style/Home.css'

function Home(props) {
  const [info, setInfo] = useState([]);
  const [employees, setEmployees] = useState({});
  const [lab, setLab] = useState({});
  const [idToEmploy, setIdToEmploy] = useState('');

  useEffect(() => {
    setLab(props.lab);
  }, [props.lab])

  useEffect(() => {
    setEmployees(lab.Employees);
    // console.log('EMPLOYEES: ', employees)
    setInfo(lab.LabInfo);
  }, [lab])

  // useEffect(() => {
  //   console.log('Employees UPDATED: ', employees)
  //   console.log('EMPLOYEES STR: ', JSON.stringify(employees))
  // }, [employees])

  const handleHire = (employeeId) => {
    props.clickSound();
    callNui('hireEmployee', { employeeId: employeeId });
  };

  return (
    <div className='home_page'>
      <h2 className="title">Gestione laboratorio</h2>
      <div className="gestione-azienda">
        <div className="info-azienda">
          <h2>Informazioni sul laboratorio</h2>
          <ul className='info-container'>
            { info &&
              Object.keys(info).map((key, idx) => {
                let translaction = TranslateStr(key)
                if (translaction == null) {
                  return
                }
                // if (key == 'DailyChest') {
                //   return
                // }
                return <Info key={idx} title={TranslateStr(key)} value={info[key]} />
              })
            }

          </ul>
        </div>

        <div className='divider'></div>

        <div className="gestione-dipendenti">
          <h2>Gestione dipendenti</h2>
          <div className='employee-assumption'>
            <h3>Assumi un dipendente</h3>
            <div>
              <input type="number" placeholder="ID Giocatore" onChange={(e) => setIdToEmploy(e.target.value)} max={999} maxLength={10}/>
              <input type="button" value="Assumi" className='employee-hire' onClick={() => handleHire(idToEmploy)}/>
            </div>
          </div>
          <h2>Lista dipendenti</h2>
          <ul className='employee-container'>
            {
              employees ?
                Object.keys(employees).map((key, idx) => {
                  return <Employee key={idx} myIdentifier={props.myIdentifier} employee={employees[key]} employeeId={key} clickSound={props.clickSound}/>
                })
              :
                <h4>Non ci sono dipendenti</h4>
            }
          </ul>
        </div>
      </div>
    </div>
  )
}

function Employee(props) {
  let employee = props.employee

  const handlePromote = () => {
    props.clickSound();
    callNui('promoteEmployee', {
      employee: props.employeeId,
    })
  }

  const handleDegrade = () => {
    props.clickSound();
    callNui('degradeEmployee', {
      employee: props.employeeId,
    })
  }

  const handleFire = () => {
    props.clickSound();
    // console.log('Firing employee: ' + employee.id)
    callNui('fireEmployee', {
      employee: props.employeeId
    })
  }

  return (
    <div className='employee'>
      <div className='employee-info'>
        <span className='employee-name'>{employee.Name}</span>
        <span className='employee-grade'>{employee.GradeLabel}</span>
      </div>
      <div className='employee-actions'>
        <span className='employee-assumption-date'>{employee.Assumption || 0}</span>
        <span className='employee-actions'>
          {
            employee.Grade != 3 && props.employeeId != props.myIdentifier ?
              employee.Grade == 1 ? 
              // SE DIPENDENTE
              (<div className='employee-buttons'>
                <button className='employee-button promote' onClick={handlePromote}>Promuovi</button>
                <button className='employee-button fire' onClick={handleFire}>Licenzia</button>
              </div>) : 
              // SE MANAGER
              (<div className='employee-buttons'>
                <button className='employee-button degrade' onClick={handleDegrade}>Degrada</button>
                <button className='employee-button fire' onClick={handleFire}>Licenzia</button>
              </div>)
            :
              // SE CEO
            ""

          }
        </span>
      </div>
    </div>
  )
}

function Info(props) {
  return (
    <li className='info-item'>
      <span className='info-title'>{props.title}</span>
      <span className='info-value'>{props.value}</span>
    </li>
  )
}

export default Home