import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // h initialize() kaleitai otan energopoieitai o controller gia prwth fora
  //antitheta h connect() kaleitai kathe fora pou o controller ginetai connected sto DOM
  initialize() {
    // Select the node that will be observed for mutations
    const rooms = document.getElementById("rooms")  // pairnw to rooms element, mesw tou id="rooms" sto index page
    this.sortRooms(rooms) // kanei sort ta rooms analoga me to time tou latest message tou kathenos, alla den kanei reposition to room mesa sth lista
    // gia na kanw modify ti lista me ta rooms opote kapoio room exei to neotero mhnyma xrsimopoiw to mutationObserver
    // auto akouei gia allages sto rooms DOM element (alla kai sta children tou)
    // opote kati prostithetai sto rooms DOM kanei modify ti lista se sorted 
    // https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver
    this.mutationObserver(rooms)
  }

  mutationObserver(rooms) {
    // Options for the observer (which mutations to observe)
    const config =  { attributes: true, childList: true, subtree: true }
    // Callback function to execute when mutations are observed
    const callback = (mutationsList, observer) => {
      for (const mutation of mutationsList) {
        if (mutation.type === "childList") {  // true otan stelnw h dexomai ena mhnyma
          const sortRoomList = sortRoomsByLatestMessage(rooms)  // kanw create th sorted list kalwntas thn sortRoomsByLatestMessage pou exw orisei parakatw 
          broadcastSortedRooms(rooms, sortRoomList, observer, config) // kanei update tin lista me ta rooms se kathe allagh
        }
      }
    }
    // Create an observer instance linked to the callback function
    const observer = new MutationObserver(callback)
    // Start observing the target node for configured mutations
    observer.observe(rooms, config)
  }

  sortRooms(rooms) {
    const sortRoomList = sortRoomsByLatestMessage(rooms)  // pairnw ti lista kanwntas sort ta rooms analoga me to time tou teleutaiou message tou kathenos
    rooms.innerHTML = ""  // otan teleiwsw to sorting, afairw to HTML content tou element me id="rooms"
    sortRoomList.forEach(room => {  // gia kathe room sti lista twn rooms
      rooms.appendChild(room)   // kanw append to room sto element "rooms" tou DOM
    })
  }
}

function broadcastSortedRooms(rooms, sortRoomList, observer, config) {
  observer.disconnect() //afairw ton observer, epeidh den thelw na akouei pia gia allages afou auth h synarthsh tha kanei reposition ta rooms, alliws tha kanei loop mesa sthn idia synarthsh
  rooms.innerHTML = ""  // set to HTML content tou element se empty string
  sortRoomList.forEach((room) => { // gia kathe room sti sorted list twn rooms
    rooms.appendChild(room) // to kanw append sti lista, dhladh to sorted list twn children ginetai append stin lista twn rooms
  })
  observer.observe(rooms, config) // otan teleiwsw, vazw ton observer na kanei observe ta idia arguments
}

// kanei sort th rooms list analoga me to timestamp tou latest message
function sortRoomsByLatestMessage(rooms) {
  const roomList = rooms.querySelectorAll(".public-room") // pairnw ola ta elements me class name "public-room" tou partial _room
  // pairnw tin roomList pou periexei ola ta rooms kai tin metatrepw se pinaka (Array) kai kalw tin sort pou pairnei 2 rooms (room1, room2) kai kanei comparisons metaksy twn rooms
  const sortRoomList = Array.from(roomList).sort((room1, room2) => {
    // sto _latest_message partial, kanw set to time tou latest_message mesa sto data
    // vazw ? ws elegxo, kathws mporei na mhn yparxei kanena mhnyma sto room, opote to time tha einai nil
    // opote kalei to dataset mono ean to querySelector(".latest-msg-time") den einai null
    // xrhsimopoiw to dataset? gia na diabasw to custom data attribute time
    const room1LatestMsg = room1.querySelector(".latest-msg-time")?.dataset?.time // pairnw to time tou teleutaiou mhnymatos gia to room1
    const room2LatestMsg = room2.querySelector(".latest-msg-time")?.dataset?.time // pairnw to time tou teleutaiou mhnymatos gia to room2

    // pws ginetai sorted h lista
    if (room1LatestMsg === undefined) { // an den yparxei latest message sto room1 (undefined)
      return 1  // to room1 paei meta to deutero sti lista
    } else if (room2LatestMsg === undefined) {  // an den yparxei latest message sto room2 (undefined)
      return -1 // to room1 paei prin to deutero sti lista
    } else {
      return room1LatestMsg > room2LatestMsg ? -1 : 1 // px. an to time tou latest message tou room1 einai megalytero tou room2, shmainei oti einai pio prosfato to message tou room1
                                                      // ara to room1 paei prin to deutero sti lista
                                                      
    }
  })
  return sortRoomList // epistrefw tin sorted list
}

