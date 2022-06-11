import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
  static targets = [ "clearquery" , "clearusername"]

  connect() { console.log("reset search controller connected") }

  clean() {
    //console.log(this.clearmeTarget)
    this.clearqueryTarget.value=''
    this.clearusernameTarget.value=''
  }
}