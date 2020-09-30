import {Socket, Presence} from "phoenix"

class App {

  static init(){
    let socket = new Socket("/play", {params: {token: window.gameToken}})
    socket.connect()

    let $board = document.querySelector("#grid")

    socket.onOpen( () => console.log("socket OPEN") )
    socket.onError( e => console.log("socket ERROR", e) )
    socket.onClose( () => console.log("socket CLOSE") )

    let channel = socket.channel("game:board", {})
    channel.join()
           .receive("ok", () => { console.log("Joined successfully") })
           .receive("error", resp => {
             console.log("Unable to join", resp)

             if (resp.reason == "game over") {
               // TODO: call server to clear session cookie
               socket.disconnect()
             }
           })
    channel.onError( e => console.log("channel ERROR", e) )
    channel.onClose( () => console.log("channel CLOSE") )

    let presences = {}
    channel.on("presence_state", state => {
      presences = Presence.syncState(presences, state)
      this.render(presences, $board)
    })
    channel.on("presence_diff", diff => {
      presences = Presence.syncDiff(presences, diff)
      this.render(presences, $board)
    })
  }

  static render(presences, $board){
    let template = document.createElement('template')
    template.innerHTML = this.htmlTemplate(presences)

    let $heroes = $board.querySelector(".hero-cells")
    $heroes.replaceWith(template.content)
  }

  static htmlTemplate(presences){
    let heroes = Presence.list(presences, (_id, {metas: [hero, ...rest]}) => {
      let position = this.gridPlot(hero)
      let style = `grid-column: ${position.col}; grid-row: span 1 / ${position.row};`

      return `<div class="hero" style="${style}"></div>`
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
