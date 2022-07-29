// orizw kapoies methodous pou epitrepoun na yparxei epikoinwnia metaksy tou js activity_channel me to activity_channel tou action cable
// kai to activity_channel tha mporei na epikoinwnei me to user model xrhsimopoiwntas ton current_user helper

// vasismeno sto https://guides.rubyonrails.org/action_cable_overview.html#streams
// 6.1 Example 1: User Appearances

import consumer from "./consumer"

let handleReset; // helper function pou xrhsimopoiw gia tous event handlers
let timer = 0;  // ta xrhsimopoia gia na kanw reset to away status

consumer.subscriptions.create("ActivityChannel", {
  initialized() { // called once on load

  },

  connected() {
    // Called when the subscription is ready for use on the server
    console.log("Connected");
    // initialize reset function
    // xreiazomai tin handleReset stous event handlers
    handleReset =  () => this.resetTimer(this.uninstall); // den mporw na diagrapsw ena event apo to window an den exw ena reference sto event
    this.install(); // add event handlers
    // thelw na akouw gia turbo:load event kai otan sumbei auto, kalw tin resetTimer
    // otan kanw navigation se diaforetika pages thelw to user activity status na ginetai updated
    window.addEventListener("turbo:load", () => this.resetTimer()); // turbo:load fires once after the initial page load, and again after every Turbo visit.
    // prepei sto index view twn rooms na exw ena frame pou na akouei gia turbo:load
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
    console.log("Disconnected");
    this.uninstall();
  },

  rejected() {
    // Called when the subscription is rejected by the server.
    console.log("Rejected");
    this.uninstall(); // se periptwsh pou eixa kati installed 
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
  },

  online() {
    console.log("online");
    // appear online
    this.perform("online"); //to string online einai to onoma tis methodou pou kalw (apo to activity_channel.rb)
    //kalei tin online tou activity_channel.rb pou thetei to status se online
  },
  away() {
    console.log("away");
    // appear away
    this.perform("away"); //to string away einai to onoma tis methodou pou kalw (apo to activity_channel.rb)
    //kalei tin away tou activity_channel.rb pou thetei to status se away
  },
  offline() {
    console.log("offline");
    // appear offline
    this.perform("offline");  //to string offline einai to onoma tis methodou pou kalw (apo to activity_channel.rb)
    //kalei tin offline tou activity_channel.rb pou thetei to status se offline
  },

  // otan thelw na kanw unistall, shmainei oti o user den einai pia sto rooms index page
  uninstall() {
    //xrhsimopoiw to <div id="activity_channel"> tou index.html.erb
    const checkPage = document.getElementById("activity_channel"); // pairnw to element activity_channel tou index page
    if (!checkPage) { // (! = false), an den vrw to element sto index (den vrisketai o user sto index H den exei ginei akoma load to page )
      clearTimeout(timer);  // kanw clear to timer
      this.perform("offline"); // kalw tin offline tou activity_channel.rb pou kanei update to status se offline kai to kanei broadcast se olous
    }
  },
  install() {
    console.log("Install");
    // arxika afairw ola ta event listeners se periptwsh pou eixa kapoio
    window.removeEventListener("load", handleReset);
    window.removeEventListener("DOMContentLoaded", handleReset);
    window.removeEventListener("click", handleReset);
    window.removeEventListener("keydown", handleReset);

    // 
    window.addEventListener("load", handleReset);
    window.addEventListener("DOMContentLoaded", handleReset);
    window.addEventListener("click", handleReset);
    window.addEventListener("keydown", handleReset);
    this.resetTimer();  // to logic gia to away status
  },

  // gia to away status
  resetTimer() {
    this.uninstall(); // checkarei an eimai sto swsto page, an eimai den tha to treksei kai to timer tha synexisei
    const checkPageAgain = document.getElementById("activity_channel"); // checkarw ksana an eimai sto swsto page opws sto uninstall
    if (!!checkPageAgain) { // (!! = true), eimai sto swsto page
      this.online();  // kanw to status
      clearTimeout(timer); // clear timer gia na arxisei apo to 0 na metraei gia poso eimai online
      //edw kanw define to timer
      const timeInSeconds = 10;  // thelw na eimai online gia 5 deuterolepta, mporw na to allaksw se osa thelw
      // to timeout pairnei tin wra se milliseconds ara prepei na metatrepsw ta seconds se milli
      const milliseconds = 1000;
      const timeInMilliseconds = timeInSeconds * milliseconds;
      //orizw ti diarkeia tou timer gia na paw se away status
      timer = setTimeout(this.away.bind(this), timeInMilliseconds); // bind(this) giati xreiazomai to context gia na mporw akoma na kalw tin away
    }
  },
});
