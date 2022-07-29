// elegxw an o currect user einai admin
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="check-current-user"
export default class extends Controller {
  connect() {
    if (this.currentUserRole == "admin") {
      this.element.classList.remove("d-none")
    }
  }

  get currentUserRole() {
    return document.querySelector("[name='current-user-role']").content
  }
}