import React from 'react'

import { useState, useEffect } from 'react'
import { useNui, callNui } from "../hooks/FiveM.js"

import craftingEmptyIcon from '../../assets/images/crafting-empty.png'

import './style/Crafting.css'

import { Line } from 'rc-progress';

function Crafting(props) {

  const [craftingItems, setCraftingItems] = useState(props.config.CraftingList || null)
  const [craftingSets, setCraftingSets] = useState(props.craftingSets || {'default': ''})
  const [craftingTables, setCraftingTables] = useState(props.lab.Crafting.Tables || null)

  useEffect(() => {
    setCraftingTables(props.lab.Crafting.Tables)
    setCraftingSets(props.lab.Crafting.Recipes)
  }, [props.lab])

  return (
    <div className='crafting_page'>
      <h2 className="title">Crafting</h2>
      <div className="crafting_list">
        { craftingItems && 
          Object.keys(craftingItems).map((key, index) => {
            let item = craftingItems[key]

            if (craftingSets[item.set] !== undefined || item.set === 'default' || item.set === undefined) {
              return (
                <CraftingItem
                  key={index}
                  item={item}
                  craftingTables={craftingTables}
                  setCraftingTables={(newCt) => {setCraftingTables(newCt)}}
                />
              )
            }

            return null;
          })
        }
        {/* <CraftingItem item={{ name: 'test', result: {name: 'test', count: 1}, time: 10}} craftingTables={craftingTables} setCraftingTables={(newCt) => {setCraftingTables(newCt)}} /> */}
      </div>
      <div className="crafting_tables">
        { craftingTables && craftingItems && 
          craftingTables.map((table, index) => {
            return (
              <CraftingTable
                key={index}
                id={index}
                locked={table.locked}
                item={craftingItems[index]}
                craftingTables={craftingTables}
                setCraftingTables={(newCt) => {setCraftingTables(newCt)}}
              />
            )
          })
        }
      </div>
    </div>
  )
}

function CraftingRequirement(props) {
  let item = props.item
  return (
    <div className="crafting_requirement">
      <img src={'nui://qs-inventory/html/images/'+(item.img || item.name)+'.png'} alt={item.name} />
      <span>x{item.count}</span>
    </div>
  )
}

function CraftingItem(props) {

  const handleCraftButton = () => {
    callNui('startCraft', {
      item: props.item,
    })
  }

  let item = props.item
  // console.log('ITEM: ' + JSON.stringify(item))
  let requirements = item.requirements;
  let result = item.result;

  return (
    <div className="crafting_item">
      <div className="crafting_data">
        <img src={'nui://qs-inventory/html/images/'+(result.name)+'.png'} alt={item.name} />
        <div className="crafting_item_info">
          <h3>{result.label}</h3>
          <div className="crafting_requirements">
            {
              requirements && 
              requirements.map((req, index) => {
                return (
                  <CraftingRequirement
                    key={index}
                    item={req}
                  />
                )
              })
            }
          </div>
          <div className="crafting_info"></div>
        </div>
        <div className='crafting_item_qty'>
          x{result.count}
        </div>
      </div>
      <div className="crafting_buttons">
        <span className='crafting_time'><b>Tempo:</b> {item.time || 10} secondi</span>
        <button className="crafting_button"
          onClick={handleCraftButton}
        >Craft</button>
      </div>
    </div>
  )
}

function CraftingTable(props) {

  const [crafting, setCrafting] = useState(null)
  const [craftingPercent, setCraftingPercent] = useState(0)
  const [craftingTimeFormatted, setCraftingTimeFormatted] = useState('00:00')

  // useEffect(() => {
  //   console.log('CRAFTING PERCENT UPDATE')
  //   console.log(craftingPercent)
  // }, [craftingPercent])

  useEffect(() => {

    // console.log('CRAFTING UPDATE, THE TABLE IS NOW UPDATING');

    // console.log(parseInt(craftingPercent));

    setCrafting(props.craftingTables[props.id].item)
    setCraftingPercent(Math.round(parseInt(props.craftingTables[props.id].percentage).toFixed(0)))
    if (props.craftingTables[props.id].item == null) {
      setCraftingTimeFormatted('00:00')
    } else {
      setCraftingTimeFormatted(formatTime(props.craftingTables[props.id].remainingTime))
    }
  }, [props.craftingTables])

  const formatTime = (time) => { 
    let minutes = Math.floor(time / 60);
    let seconds = time - minutes * 60;
    if (minutes < 10) {
      minutes = '0' + minutes;
    }
    if (seconds < 10) {
      seconds = '0' + seconds;
    }
    return minutes + ':' + seconds;
  }

  const resetTable = () => {
    callNui('resetCraft', {
      id: props.id,
    })
  }

  return (
    <div className="crafting_table">
      {
        !props.locked &&
        !crafting &&
        <div className='locked-crafting-table'>
          <img src={craftingEmptyIcon} alt="empty" />
          <span>Libera</span>
        </div>
      }
      {
        props.locked &&
        <div className="locked-crafting-table">
          <img src="https://creazilla-store.fra1.digitaloceanspaces.com/emojis/58783/locked-emoji-clipart-md.png" alt="locked" />
          <span>Bloccata</span>
        </div>
      }
      {
        crafting && crafting !== null && !props.locked &&
        <>
          <div className="ct_crafting_item">
            <img src={'nui://qs-inventory/html/images/'+(crafting.result.name)+'.png'} alt={crafting.result.name} />
            <div className="crafting_data">
              <h2>{crafting.result.label}</h2>
              <div className="crafting_requirements">
                {
                  crafting.requirements.map((req, index) => {
                    return (
                      <CraftingRequirement
                        key={index}
                        item={req}
                      />
                    )
                  })
                }
              </div>
            </div>
            <span className='crafting_item_qty'>x{crafting.result.count}</span>
          </div>
          <div className="ct_crafting_info">
            <Line percent={craftingPercent} strokeWidth={7} trailWidth={7} strokeLinecap="square" className="craft-progbar" trailColor="#170045" strokeColor="#4100c4" />

            <div className='ct_crafting_time'>
              <span>{isNaN(craftingPercent) ? '0' : craftingPercent}%</span>
              {
                craftingPercent >= 100 &&
                <button className="crafting_button deposit" onClick={resetTable}>Ritira</button>
              }
              {
                craftingPercent < 100 &&
                <span>{craftingTimeFormatted}</span>
              }
            </div>
          </div>
        </>
      }
    </div>
  )
}

export default Crafting