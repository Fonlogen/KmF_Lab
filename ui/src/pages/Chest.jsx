import React from 'react'

import './style/Chest.css'
import { useState, useEffect } from 'react'

function Chest({ click, lab, config }) {

  const [chest, setChest] = useState(lab.LabInfo.DailyChest)
  const [currentTime, setCurrentTime] = useState(0)
  const [chestTime, setChestTime] = useState(0)

  // I want current Y-m-d H:M:S in seconds, i want to update it every second
  useEffect(() => {
    let ct = new Date()
    ct = ct.getTime() / 1000
    // Remove the milliseconds
    ct = Math.floor(ct)
    setCurrentTime(ct)

    setInterval(() => {
      ct = new Date()
      ct = ct.getTime() / 1000
      // Remove the milliseconds
      ct = Math.floor(ct)
      setCurrentTime(ct)
    }, 1000)

  }, [])

  useEffect(() => {
    // console.log('CT UPDATED')
    // console.log(currentTime)
    let calc = Math.floor(chest) - Math.floor(currentTime)
    if (calc <= 0) setChestTime(0)
    else setChestTime(calc)

    // console.log('CHEST TIME, CHEST, CURRENT TIME', chestTime, chest, currentTime)

  }, [currentTime])

  // useEffect(() => {
  //   // console.log('CHEST TIME UPDATED')
  //   // console.log(chestTime)
  //   // console.log('CHEST TIME', chestTime)
  // }, [chestTime])

  const secondsToHMS = (seconds) => {
    if (seconds <= 0) return '00:00:00'
    const h = Math.floor(seconds / 3600)
    const m = Math.floor(seconds % 3600 / 60)
    const s = Math.floor(seconds % 3600 % 60)

    const hDisplay = h > 0 ? (h < 10 ? '0' + h : h) + ':' : ''

    const mDisplay = m > 0 ? (m < 10 ? '0' + m : m) + ':' : '00:'

    const sDisplay = s > 0 ? (s < 10 ? '0' + s : s) : '00'

    return hDisplay + mDisplay + sDisplay
  }

  // I have dd/mm/YYYY hh:mm:ss in seconds, i only want to get hh:mm:ss
  const getHour = (seconds) => {
    const date = new Date(seconds * 1000)

    const h = date.getHours()
    const m = date.getMinutes()
    const s = date.getSeconds()

    const hDisplay = h > 0 ? (h < 10 ? '0' + h : h) + ':' : ''

    const mDisplay = m > 0 ? (m < 10 ? '0' + m : m) + ':' : '00:'

    const sDisplay = s > 0 ? (s < 10 ? '0' + s : s) : '00'

    return hDisplay + mDisplay + sDisplay
  }

  const getCase = (lab) => {
    fetch('https://KmF_Lab/freeChest', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        lab: lab,
      })
    })

    setChest(currentTime + 86400)
    setChestTime(86400);
  }

  return (
    <div className='chest_page'>
      <h2 className="title">Cassa gratuita giornaliera</h2>
      <div className='chest-container'>
        {
          chestTime > 0 &&
          <div className='free-daily-chest'>
            <h2 className='free-chest-title'>La cassa sarà disponibile tra:</h2>
            <h3 className='free-chest-time'>{secondsToHMS(chestTime) || 'N/A'}</h3>
          </div>
        }
        {
          chestTime <= 0 &&
          <div className='free-daily-chest'>
            <h2 className='free-chest-title'>La cassa è disponibile!</h2>
            <button className='free-chest-btn' onClick={() => getCase(lab)}>Ottieni cassa</button>
          </div>
        }
      </div>
    </div>
  )
}

export default Chest