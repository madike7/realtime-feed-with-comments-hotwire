import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
  static targets = [ "clearquery" , "clearusername"]

  connect() { console.log("reset search controller connected") }

  clean() {
    // kanw clear kai ta duo targets
    this.clearqueryTarget.value=''  
    this.clearusernameTarget.value=''
  }
}