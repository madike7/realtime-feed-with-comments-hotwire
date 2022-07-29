//elegxw an o current_user einai o author
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="check-author"
export default class extends Controller {
  static values = {
    authorId: String
  }

  connect() {
    // an o current user einai o author tou message, h eiani admin
    if (this.currentUserId === this.authorId || this.currentUserRole == "admin") {
      this.element.classList.remove("d-none") // afainw to display none wste na emfanizetai to delete button
      // this.deleteTarget.classList.remove("d-none")
    }
  }

  get authorId() {
    return this.authorIdValue
  }

  get currentUserId() {
    return document.querySelector("[name='current-user-id']").content
  }

  get currentUserRole() {
    return document.querySelector("[name='current-user-role']").content
  }
}