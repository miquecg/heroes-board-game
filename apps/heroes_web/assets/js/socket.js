import {Socket, Presence} from "phoenix"

class App {

  static init(){
    const socket = new Socket("/game/socket", {params: {token: window.gameToken}})
    socket.connect()

    const $board = document.querySelector("#grid")
    let hero = ""

    socket.onOpen( () => console.log("socket OPEN") )
    socket.onError( e => console.error("socket ERROR", e) )
    socket.onClose( () => console.log("socket CLOSE") )

    const channel = socket.channel("game:board", {})
    channel.join()
           .receive("ok", resp => {
             hero = resp.hero
             console.log(`id:${hero} Joined successfully`)
           })
           .receive("error", resp => {
             console.error(`reason:${resp.reason} message:${resp.message}`)

             if (resp.reason == "unauthorized") {
               socket.disconnect()
               this.clearSession()
                   .then( () => {
                     window.location.reload()
                   })
             }
           })
    channel.onError( e => console.error("channel ERROR", e) )
    channel.onClose( () => console.log("channel CLOSE") )

    let presences = {}
    channel.on("presence_state", state => {
      presences = Presence.syncState(presences, state)
      this.render(presences, $board, hero)
    })
    channel.on("presence_diff", diff => {
      presences = Presence.syncDiff(presences, diff)
      this.render(presences, $board, hero)
    })

    const handler = this.keyboardHandler( cmd => {
      channel.push("game:board", {cmd: cmd})
             .receive("error", error => {
               console.error(`command:${cmd} message:${error.message}`)
               throw new Error(error.reason)
             })
    })
    window.addEventListener("keydown", handler, true)

    channel.on("game_over", () => {
      window.removeEventListener("keydown", handler, true)
      this.clearSession()
          .then( () => {
            if (window.confirm("\t    GAME OVER\n\n\nDo you want to play again?")) {
              window.location.reload()
            }
          })
    })
  }

  static render(presences, $board, id){
    const fragment = this.htmlFragment(presences, id)

    $board.querySelector(".hero-cells")
          .replaceChildren(fragment)
  }

  static htmlFragment(presences, id){
    const fragment = new DocumentFragment()

    Presence.list(presences, (key, {metas: [hero, ...rest]}) => {
      hero = {...hero, isPlayer: id == key}

      const div = document.createElement("div")
      div.className = this.divClass(hero)
      div.style = this.divGridStyle(hero)

      fragment.appendChild(div)
    })

    return fragment
  }

  static divClass(hero){
    let className = "hero"

    if (hero.state == "dead") {
      return className += " dead"
    }

    if (hero.isPlayer) {
      return className += " player"
    }

    return className
  }

  static divGridStyle(hero){
    return `grid-column: ${1 + hero.x}; grid-row: span 1 / ${-1 - hero.y};`
  }

  static keyboardHandler(sendCommand){
    return e => {
      if (e.defaultPrevented) {
        return
      }

      if (e.repeat) {
        return
      }

      switch (e.key) {
        case "ArrowUp":
          sendCommand("↑")
          break
        case "ArrowDown":
          sendCommand("↓")
          break
        case "ArrowLeft":
          sendCommand("←")
          break
        case "ArrowRight":
          sendCommand("→")
          break
        case " ":
          sendCommand("⚔")
          break
        default:
          return
      }

      event.preventDefault()
    }
  }

  static async clearSession(){
    const response = await fetch("/game/session", {
      method: "DELETE",
      headers: {
        "x-csrf-token": window.csrfToken
      }
    })

    if (!response.ok) {
      throw new Error("Cannot clear session")
    }

    return response
  }
}

( () => { App.init() } )()

export default App
