import React from 'react'

import { useState, useEffect } from 'react'

import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faPlus, faX } from '@fortawesome/free-solid-svg-icons'

import { useNui, callNui } from '../hooks/FiveM.js'

import './style/Deposit.css'

function Deposit(props) {

  const [config, setConfig] = useState(props.config || {})

  const [depositItems, setDepositItems] = useState(props.lab.Deposit || 0)

  const [inventoryItems, setInventoryItems] = useState()


  const [totalDepositItems, setTotalDepositItems] = useState(0)

  // const [itemToWithdraw, setItemToWithdraw] = useState(null)
  // const [depositItemQty, setDepositItemQty] = useState(0)

  useEffect(() => {
    // console.log('UPDATING DEPOSIT')
    setDepositItems(props.lab.Deposit)
    let depositTot = 0
    Object.keys(props.lab.Deposit).map((item, index) => {
      depositTot += parseInt(props.lab.Deposit[item].qty)
    })
    setTotalDepositItems(depositTot)
  }, [props.lab.Deposit])

  const addDepositItem = () => {
    props.clickSound();

    useNui('SetInventoryItems', (data) => {
      // console.log('INVENTORY ITEMS', data)

      let items = []

      Object.keys(data).map((item, index) => {
        // console.log(data[item])
        items[item] = data[item]
      })

      setInventoryItems(items);
    })

    callNui('GetInventoryItems', {});

    setShowingDepositDialog(true)
  }

  const handleItemDeposit = () => {
    props.clickSound();

    // console.log('ITW: ', JSON.stringify(itemToWithdraw))
    // console.log('QTY: ', JSON.stringify(depositItemQty))

    callNui('AddItemToDeposit', {
      item: itemToWithdraw,
      qty: depositItemQty
    })
    setShowingDepositDialog(false)
  }

  return (
    <div className='deposit_page'>
      <h2 className="title">Deposito</h2>
      <div className="deposit_items">
        {
          props.config.WhitelistedDepositItems && props.config.WhitelistedDepositItems != null &&
          Object.keys(props.config.WhitelistedDepositItems).map((item, index) => {
            let found = false;
            let founditem = null;
            Object.keys(depositItems).map((depositItem, depositIndex) => {
              // console.log('DEPOSIT ITEM: ' + JSON.stringify(depositItems[depositItem]));
              if (depositItems[depositItem].name == props.config.WhitelistedDepositItems[item].name) {
                found = true;
                founditem = depositItems[depositItem];
                return;
              }
            })
            if (found) return <DepositItem item={founditem} chooseDeposit={props.config.WhitelistedDepositItems[item].chooseDeposit || false} chooseWithdraw={props.config.WhitelistedDepositItems[item].chooseWithdraw || false} key={index} />
            // console.log('DIVERSO! DIO CANE');
            return <DepositItem item={props.config.WhitelistedDepositItems[item]} chooseWithdraw={props.config.WhitelistedDepositItems[item].chooseWithdraw || false} chooseDeposit={props.config.WhitelistedDepositItems[item].chooseDeposit || false} key={index} clickSound={props.clickSound} />
          })
        }
      </div>
      <div className="deposit_info">
        <div className="deposit_info_item">
          <span className="deposit_info_title">Totale oggetti:</span>
          <span className="deposit_info_value">{totalDepositItems || 0}</span>
        </div>

        <div className="deposit_info_item">
          <span className="deposit_info_title">Capacità totale:</span>
          <span className="deposit_info_value">{props.lab.LabInfo.MaxDeposit || 100}</span>
        </div>
      </div>
    </div>
  )
}

function DepositItem(props) {
  let item = props.item
  let chooseDeposit = props.chooseDeposit
  let chooseWithdraw = props.chooseWithdraw

  // console.log('QTY: ' + item.qty)
  // console.log('ITEM: ' + JSON.stringify(item));

  const [depositDialog, showDepositDialog] = useState(false);
  const [withdrawDialog, showWithdrawDialog] = useState(false);
  const [depositItemQty, setDepositItemQty] = useState(0);
  const [withdrawItemQty, setWithdrawItemQty] = useState(0);

  const handleItemDeposit = () => {
    if (depositItemQty <= 0) return
    callNui('AddItemToDeposit', {
      item: item.name,
      qty: depositItemQty == 0 ? 1 : depositItemQty
    })
    showDepositDialog(false)
    setDepositItemQty(0)
  }

  const handleItemWithdraw = () => {
    if (item.qty <= 0) return
    callNui('withdrawDepositItem', {
      item: item.name,
      qty: withdrawItemQty == 0 ? 1 : withdrawItemQty
    })
    showWithdrawDialog(false)
    setWithdrawItemQty(0)
  }

  return (
    <div className='deposit_item'>

      {
        depositDialog &&
        <>
        <div className="deposit-dialog">
          <div className="header">
            <h3 className="title">Deposita</h3>
            <button className="close" onClick={
              () => {
                showDepositDialog(false)
              }
            }>
              <FontAwesomeIcon icon={faX} />
            </button>
          </div>
          

          <div className="deposit-dialog-container">
            {/* <div className="deposit-dialog-group">
              <span>Oggetto da depositare</span>
              <input type='text' readOnly value={item.label} />
            </div> */}
            <div className="deposit-dialog-group">
              <span>Quantità</span>
              <input type="number" name="qty" onChange={(e) => setDepositItemQty(e.target.value)} />
            </div>
            <div className="deposit-dialog-group">
              <button 
                className="deposit-dialog-btn deposit"
                onClick={handleItemDeposit}                    
              >Deposita</button>
            </div>
          </div>
        </div>
        {/* <div className="deposit-blocked"></div> */}
        </>
      }

      {
        withdrawDialog &&
        <>
        <div className="deposit-dialog">
          <div className="header">
            <h3 className="title">Ritira</h3>
            <button className="close" onClick={
              () => {
                showWithdrawDialog(false)
              }
            }>
              <FontAwesomeIcon icon={faX} />
            </button>
          </div>
          

          <div className="deposit-dialog-container">
            <div className="deposit-dialog-group">
              <span>Quantità</span>
              <input type="number" name="qty" onChange={(e) => setWithdrawItemQty(e.target.value)} />
            </div>
            <div className="deposit-dialog-group">
              <button 
                className="deposit-dialog-btn deposit"
                onClick={handleItemWithdraw}                    
              >Ritira</button>
            </div>
          </div>
        </div>
        </>
      }

      <div className="add_deposit_item" 
        onClick={ () => {
          if (!chooseDeposit) {
            // console.log('NO CHOOSE DEPOSIT')
            callNui('AddItemToDeposit', {
              item: item.name,
              qty: 1
            })
            return
          }
          // console.log('SHOWING DEPOSIT DIALOG')
          showDepositDialog(true)
          return;
        }}>
        <FontAwesomeIcon icon={faPlus} />
      </div>
      <span className='item_qty'>x{item.qty ? item.qty < 0 ? '0' : item.qty : 0}</span>
      <img className='deposit_item_img' src={'nui://qs-inventory/html/images/'+(item.img || item.image || item.name)+'.png'} alt={item.label} />
      <div className="item_info">
        <h3 className="item_title">{item.label}</h3>
        {/* <p className="item_description">{item.description}</p> */}
      </div>
      <div className="item_actions">
        <button className="item_action withdraw" 
          onClick={() => {
            if (!chooseWithdraw) {
              callNui('withdrawDepositItem', {
                item: item.name,
                qty: 1
              })
              return
            }
            showWithdrawDialog(true)
            return;
          }}
        >Ritira</button>
        {/* <button className="item_action deposit">Deposita</button> */}
      </div>
    </div>
  )
}

export default Deposit