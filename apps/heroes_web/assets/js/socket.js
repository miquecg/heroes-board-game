import {Socket, Presence} from "phoenix"

class App {

  static init(){
    let socket = new Socket("/game/socket", {params: {token: window.gameToken}})
    socket.connect()

    let $board = document.querySelector("#grid")
    let hero = ""

    socket.onOpen( () => console.log("socket OPEN") )
    socket.onError( e => console.log("socket ERROR", e) )
    socket.onClose( () => console.log("socket CLOSE") )

    let channel = socket.channel("game:board", {})
    channel.join()
           .receive("ok", resp => {
             hero = resp.hero
             console.log(`id:${hero} joined successfully`)
           })
           .receive("error", resp => {
             console.log("Unable to join", resp)

             if (resp.reason == "game_over") {
               // TODO: call server to clear session cookie
               socket.disconnect()
             }
           })
    channel.onError( e => console.log("channel ERROR", e) )
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

    window.addEventListener("keydown", function handler(e) {
      function sendCommand(cmd){
        let action = {cmd: cmd}
        channel.push("game:board", action)
               .receive("error", resp => {

                 if (resp.reason == "game_over") {
                   console.log(resp.message)
                   window.removeEventListener(e.type, handler, true)
                   return
                 }

                 console.error(resp.message, action)
               })
      }

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
    }, true)
  }

  static render(presences, $board, id){
    let template = document.createElement('template')
    template.innerHTML = this.htmlTemplate(presences, id)

    let $heroes = $board.querySelector(".hero-cells")
    $heroes.replaceWith(template.content)
  }

  static htmlTemplate(presences, id){
    let heroes = Presence.list(presences, (key, {metas: [hero, ...rest]}) => {
      let position = this.gridPlot(hero)
      let css = `grid-column: ${position.col}; grid-row: span 1 / ${position.row};`
      let htmlClass = (id == key ? "hero player" : "hero")

      return `<div class="${htmlClass}" style="${css}"></div>`
    })

    return [`<div class="hero-cells">`, ...heroes, `</div>`].join("")
  }

  static gridPlot(hero){
    const cols_start = 1
    const rows_end = -1

    return {col: cols_start + hero.x, row: rows_end - hero.y}
  }
}

( () => { App.init() } )()

export default App
