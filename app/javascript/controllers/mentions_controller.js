import { Controller } from "stimulus"
import Tribute from "tributejs" //access to tribute
import Trix from "trix"

export default class extends Controller {
  static targets = [ "field" ]

  connect() {
    this.editor = this.fieldTarget.editor //reference to my richtext editor
    this.initializeTribute()  
  }

  disconnect() {
    this.tribute.detach(this.fieldTarget)
  }

  initializeTribute() {
    this.tribute = new Tribute({
      allowSpaces: true,  //epitrepei kena sto username
      lookup: 'username', //psaxnw sto username key
      values: this.fetchUsers, //request sto json endpoint gia na parw tous users 
    })
    this.tribute.attach(this.fieldTarget) //connect tribute to trix editor
    this.tribute.range.pasteHtml = this._pasteHtml.bind(this)
    this.fieldTarget.addEventListener("tribute-replaced", this.replaced)
  }

  fetchUsers(text, callback) {
    fetch(`/mentions.json?query=${text}`)
      .then(response => response.json())  //otan parw pisw response, to metatrepw se json
      .then(users => callback(users)) //array of users
      .catch(error => callback([])) //empty array an den exw users
  }

  replaced(e) {
    let mention = e.detail.item.original //dinei to json pou kanei match me to mention
    let attachment = new Trix.Attachment({ //dhmiourgw to trix attachment pernwntas to sgid kai to content
      sgid: mention.sgid,
      content: mention.content
    })
    this.editor.insertAttachment(attachment) //pernaw to attachment ston editor
    this.editor.insertString(" ") //vazw ena space sto telos gia na mhn xreiastei na pataei o user monos tou
  }

  _pasteHtml(html, startPos, endPos) {
    let position = this.editor.getPosition() //gia na kserw se poio position vriskomai mesa ston editor
    this.editor.setSelectedRange([position  - (endPos - startPos), position]) //to range gia olo to mention
    this.editor.deleteInDirection("backward")
  }
}