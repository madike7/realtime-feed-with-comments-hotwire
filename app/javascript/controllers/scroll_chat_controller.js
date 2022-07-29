import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  initialize() {  //
    this.autoScrollToBottom(messages) // otan fortwnw to chat kanei scroll sto bottom, sto neotero message
  }
  // connects otan to chat ginetai load
  connect() {
    //kathe fora pou epilegw ena chat, kanw reset to scroll position sto bottom tou chat container
    console.log("Scroll Connected")
    const messages = document.getElementById("messages") //pairnw ton container me ta messages mesw tou target id="messages"
    messages.addEventListener("DOMNodeInserted", this.resetScroll) //kalw tin resetScroll pou orizw parakatw, gia kathe neo message pou prostithetai sto chat
    this.autoScrollToBottom(messages)
  }
  //otan vgainw apo to chat room
  disconnect() {
    console.log("Scroll Disconnected")
  }

  resetScroll() {
    const distanceFromBottom = messages.scrollHeight - messages.clientHeight  // posh apostash exei to shmeio pou eimai sto scroll bar apo to bottom
    const upperScrollLimit = distanceFromBottom - 500 // posa pixel panw apo to bottom prepei na einai to position tou scroll bar mou, gia na mhn ginetai reset to scroll sto bottom otan stelnw h dexomai nea messages
    // an den vriskomai mesa sto orio tou upperScrollLimit kanw scroll down sto bottom
    if (messages.scrollTop > upperScrollLimit) {
      messages.scrollTop = messages.scrollHeight - messages.clientHeight 
    }
  }
  autoScrollToBottom(messages) {  // scroll down to the bottom
    messages.scrollTop = messages.scrollHeight - messages.clientHeight
  }
}
