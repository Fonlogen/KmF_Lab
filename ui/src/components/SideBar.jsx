import React from 'react'

import { useState, useRef } from 'react'

import { Tooltip as ReactTooltip } from "react-tooltip";

import './SideBar.css'

import shopLogo from '../../assets/images/shop.png'
import homeLogo from '../../assets/images/home.png'
import craftingLogo from '../../assets/images/crafting.png'
import attackLogo from '../../assets/images/attack.png'
import depositLogo from '../../assets/images/deposit.png'
import settingsLogo from '../../assets/images/settings.png'
import accountLogo from '../../assets/images/money.png'
import closeLogo from '../../assets/images/close.png'
import fullscreenLogo from '../../assets/images/fullscreen.png'
import chestLogo from '../../assets/images/chest.png'

function SideBar(props) {

  const closePage = () => {
    props.playSound();
    fetch('https://KmF_Lab/closeMenu');
  };

  const [locked, setLocked] = useState({
    shop: false,
    crafting: false,
    deposit: false,
    attack: false,
    // chest: false,
    settings: false,
    home: false,
    account: false,
  })

  return (
    <div className='sidebar'>
      <div className='menu-buttons'>
        <MenuPageButton key="home"        page="home"       switchPage={props.switchPage}   activePage={props.activePage}   logo={homeLogo}       ps={props.playSound}  locked={locked}  />
        <MenuPageButton key="shop"        page="shop"       switchPage={props.switchPage}   activePage={props.activePage}   logo={shopLogo}       ps={props.playSound}  locked={locked}  />
        <MenuPageButton key="crafting"    page="crafting"   switchPage={props.switchPage}   activePage={props.activePage}   logo={craftingLogo}   ps={props.playSound}  locked={locked}  />
        <MenuPageButton key="deposit"     page="deposit"    switchPage={props.switchPage}   activePage={props.activePage}   logo={depositLogo}    ps={props.playSound}  locked={locked}  />
        <MenuPageButton key="account"     page="account"    switchPage={props.switchPage}   activePage={props.activePage}   logo={accountLogo}    ps={props.playSound}  locked={locked}  />
        {/* <MenuPageButton key="chest"       page="chest"      switchPage={props.switchPage}   activePage={props.activePage}   logo={chestLogo}      ps={props.playSound}  locked={locked}  /> */}
        <MenuPageButton key="attack"      page="attack"     switchPage={props.switchPage}   activePage={props.activePage}   logo={attackLogo}     ps={props.playSound}  locked={locked}  />
      </div>
      <div className="bottom-menu-buttons">
        {/* <MenuPageButton page="settings" switchPage={props.switchPage} activePage={props.activePage} logo={settingsLogo} ps={props.playSound}  /> */}
        <MenuButton key={'settings'}  action={() => {props.toggleFullscreen(); props.playSound();}} logo={fullscreenLogo} ps={props.playSound}  />
        <MenuButton key={'close'}     action={closePage} logo={closeLogo} ps={props.playSound}  />
      </div>
    </div>
  )
}

function MenuButton(props) {
  return (
    <div
      className="page_button"
      onClick={() => {
        props.action();
        props.ps();
        // props.switchPage(props.page);
      }}
    >
      <img src={props.logo} alt="" className='menubutton-img'/>
    </div>
  )
}

function MenuPageButton(props) {

  return (
    <div
      className={"page_button" + (props.activePage == props.page ? " active_page" : "")}
      onClick={
        () => {
          props.locked &&
          Object.keys(props.locked).map((page) => {
            // console.log(page)
            if (page == props.page) {
              // console.log(props.locked[page])
              if (props.locked[page]) {
                return;
              } else {
                props.switchPage(props.page);
                props.ps();
              }
            }
          })
        }
      }
    >
      {
        props.locked &&
        Object.keys(props.locked).map((page) => {
          // console.log(page)
          if (page == props.page) {
            if (props.locked[page]) {
              return (
                <div key={props.page} className='locked-page' data-tooltip-id="my-tooltip-1">
                  <img className="lockedpage-lock" src="https://creazilla-store.fra1.digitaloceanspaces.com/emojis/58783/locked-emoji-clipart-md.png"></img>
                  <div className="locked-page-bg"></div>
                  <ReactTooltip
                    id="my-tooltip-1"
                    place="right"
                    content="In arrivo..."
                  />
                </div>
              )
            }
          }
        })
      }
      <img src={props.logo} alt="" className='menubutton-img'/>
    </div>
  )
}

export default SideBar