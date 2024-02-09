import React from 'react'

import './style/Account.css'

import { callNui } from '../hooks/FiveM.js'

function Account(props) {

  const [account, setAccount] = React.useState({
    Balance: 10000000,
    Tax: 250000
  })

  const [moneyToCharge, setMoneyToCharge] = React.useState(0)

  React.useEffect(() => {
    // console.log('Account: ', JSON.stringify(props.lab))
    setAccount(props.lab.Accounts)
  }, [props.lab])

  const rechargeAccountHandler = () => {
    // console.log('Recharge account: ', JSON.stringify(moneyToCharge))
    if (moneyToCharge > 0) {
      // console.log('Recharge account 2: ', moneyToCharge)
      callNui('rechargeAccount', {
        money: moneyToCharge
      })
    }
  }

  return (
    <div className='account_page'>
      <h2 className="title">Conto laboratorio e finanziamenti</h2>
      <div className="account_container">
        <div className="info">
          <div className="section">
            <h2>Dati finanziari</h2>
            <div className='account_info_content'>
              <p>Saldo: <span className='value'>{account.Balance || 0}</span> <span className='dollar-sign'>$</span></p>
              <p>Tassazione: <span className='value'>{account.Tax || 0}</span> <span className='dollar-sign'>$</span>/<span style={{color: 'orange'}}>7d</span></p>
            </div>
          </div>
          <div className="section">
            <h2>Ricarica del conto</h2>
            <div className='account_info_content'>
              <input type="number" name="money-to-charge" id="" placeholder={100000} onChange={(e) => setMoneyToCharge(e.target.value)} />
              <button className='charge-button' onClick={rechargeAccountHandler}>Ricarica</button>
            </div>
          </div>
        </div>
        <div className="loans section">
          <h2>Prestiti e finanziamenti</h2>
          <div className='loans-info'>
            <p>
              Se hai un idea di business che ritieni valida ma non hai i fondi necessari per portarla avanti, il nostro sistema di prestiti e' qui per te! Ma ricorda, i prestiti vanno restituiti... con gli interessi! E se non dovessi restituirli in tempo, beh...
            </p>
            <div className='loans-bottom'>
              <span>Pronto a richiedere un finanziamento?</span>
              <button className='loans-button disabled'>Presto disponibile</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Account