// kanw autoclick sto button load more posts, gia na epituxw kati san infinite scrolling sta posts
// emfanizw ta post tis epomenhs selidas xwris o user na kanei click, otan emfanizetai to button
import { Controller } from "@hotwired/stimulus"
import { useIntersection } from 'stimulus-use'

export default class extends Controller {
  options = {
    threshold: 1
  }

  connect() {
    useIntersection(this, this.options)
  }

  appear(entry) {
    this.element.click()
  }
}