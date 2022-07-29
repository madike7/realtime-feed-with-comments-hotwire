// AKRIVWS TO IDIO ME TO SORT_ROOMS_CONTROLLER
// pairnw to rooms element mesw tou id="users" tou index page
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  initialize() {
    const users = document.getElementById("users")
    this.sortUsers(users)
    this.mutationObserver(users)
  }

  mutationObserver(users) {
    const config =  { attributes: true, childList: true, subtree: true }
    const callback = (mutationsList, observer) => {
      for (const mutation of mutationsList) {
        if (mutation.type === "childList") {
          const sortUserList = sortUsersByLatestMessage(users)
          broadcastSortedUsers(users, sortUserList, observer, config)
        }
      }
    }
    const observer = new MutationObserver(callback)
    observer.observe(users, config)
  }

  sortUsers(users) {
    const sortUserList = sortUsersByLatestMessage(users)
    users.innerHTML = ""
    sortUserList.forEach(user => {
      users.appendChild(user)
    })
  }
}

function broadcastSortedUsers(users, sortUserList, observer, config) {
  observer.disconnect()
  users.innerHTML = ""
  sortUserList.forEach((user) => {
    users.appendChild(user)
  })
  observer.observe(users, config)
}

function sortUsersByLatestMessage(users) {
  const userList = users.querySelectorAll(".private-room")
  const sortUserList = Array.from(userList).sort((user1, user2) => {
    const user1LatestMsg = user1.querySelector(".latest-msg-time")?.dataset?.time
    const user2LatestMsg = user2.querySelector(".latest-msg-time")?.dataset?.time

    if (user1LatestMsg === undefined) {
      return 1
    } else if (user2LatestMsg === undefined) {
      return -1
    } else {
      return user1LatestMsg > user2LatestMsg ? -1 : 1
    }
  })
  return sortUserList
}

