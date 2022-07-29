// handle recording previews sti forma tou message
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() { // otan ginetai connect sti message form, kalw tin recordVideo() kai recordAudio() gia na mporw na kanw recordings
    this.recordVideo();
    this.recordAudio();
  }

  // Dhmiourgei ton container me ta previews twn recordings panw apo ti forma twn messages prin kanw submit

  previewRecordings() { // kaleitai sti message form otan to file_field ginetai set
    this.resetPreviews(); //arxika kanw reset ta hdh yparxonta previews giati exei allaksei to input tou file_field
    for (let i = 0; i < this.targets.element.files.length; i++) { // pairnei ta files pou exoun epilegei mesw tou file_field
      let file = this.targets.element.files[i]; // pairnw kathe file pou exei epilegei
      let element = this.createPreviewElement(file);  // dhmiourgw ena element gia kathe file, pou pairnw apo tin createPreviewElement analoga me to file type tou recording
      element.classList.add("recording-preview"); // css class gia na kanw style to preview element
      document.getElementById("preview-recordings").appendChild(element); // kanw append to element pou dhmiourghsa ston container me ta previews me id preview-recordings sti forma tou message
    }
    this.showOrHidePreviewContainer(); // o container twn previews einai arxika hidden, opote otan kanw preview ta files, ton kanw visible
  }

  showOrHidePreviewContainer() {
    let previewContainer = document.getElementById("preview-recordings"); // pairnw ton container twn previews kai an einai hidden ton kanw visible, kai to anapodo
    previewContainer.classList.toggle("d-none");  //  kanw toggle ton container analoga me to an htan hidden h oxi
  }

  // ftiaxnw to preview element gia to recording, wste na emfanizw ena icon analoga me ton typo tou file
  // Ta file types pou dexomai einai : 
  // Audio -> ogg, mp3, wav
  // Video -> webm, mp4, quicktime
  // epistrefei to element pou ginetai added sto DOM
  createPreviewElement(file) {
    let element;
    // orizw tin cancelUpload function pou tha pernaw sti dhmiourgia tou element
    // tin kanw assign se mia anonymous function pou kalei tin removeElementPreview
    let cancelUpload = (e) => this.removeElementPreview(e); // kaleitai otan kanw click sto cancel button se ena preview element
    switch (file.type) {  // kanw switch analoga me to file.type tou active storage file
      // cases an to recording einai Video
      case "video/mp4":
      case "video/quicktime":
      case "video/mpeg":
      case "video/webm":
      case "video/webm;codecs=vp9":
        element = this.videoPreview(cancelUpload);  // kalw tin videoPreview gia na dhmiourghsw to icon tou preview element
        break;
      // cases an to recording einai Audio
      case "audio/mp3":
      case "audio/mpeg":
      case "audio/wav":
      case "audio/webm":
      case "audio/webm; codecs=opus":
      case "audio/ogg":
      case "audio/ogg; codecs=opus":
      case "video/ogg":
      case "audio/x-wav":
        element = this.audioPreview(cancelUpload); // kalw tin audioPreview gia na dhmiourghsw to icon tou preview element
        break;
      // se kathe allh periptwsh emfanizw ena element pou deixnei oti to file type den einai supported
      default:
        element = this.notSupportedPreview(cancelUpload);
    }
    element.dataset.filename = file.name; // thetw to filename tou element na einai idio me to name tou file pou kanw preview
    return element; // epistrefw to element
  }

  /* dhmiourgw preview elements gia ta audio recordings
     cancelUpload - h function pou kalw otan kanw click sto cancel button
     epistrefei to HTMLElement - to element pou vazw sto DOM */
  audioPreview(cancelUpload) {
    let cancelBtn, element; // dhmiourgw dyo empty vars gia to cancel button kai to element
    element = document.createElement("i"); // dhmiourgw ena element ws icon, giati den thelw na kanw to audio preview playable, alla na fainetai ti typos arxeiou einai
    element.classList.add("bi", "bi-file-music-fill");  // css styling gia to element
    cancelBtn = document.createElement("i");  // dhmiourgw to cancel button gia to upload, san icon
    cancelBtn.classList.add("bi", "bi-trash-fill", "cancel-btn"); // css styling gia to cancel button, wste na emfanizetai panw apo to preview element
    cancelBtn.onclick = cancelUpload; // otan kanw click sto cancel button kalw tin cancelUpload function
    element.appendChild(cancelBtn); // kanw append to to cancel button sto i tou element, wste na mporw na to diagrapsw
    return element; // epistrefw to element pou kanw add sto DOM
  }

  /* dhmiourgw preview elements gia ta video recordings
     cancelUpload - h function pou kalw otan kanw click sto cancel upload button
     epistrefei to HTMLElement - to element pou vazw sto DOM */
  videoPreview(cancelUpload) {
    let cancelBtn, element; // dhmiourgw dyo empty vars gia to cancel button kai to element
    element = document.createElement("i"); // dhmiourgw ena element ws icon, giati den thelw na kanw to video preview playable, alla na fainetai ti typos arxeiou einai
    element.classList.add("bi", "bi-file-play-fill");  // css styling gia to element
    cancelBtn = document.createElement("i");  // dhmiourgw to cancel button gia to upload, san icon
    cancelBtn.classList.add("bi", "bi-trash-fill", "cancel-btn"); // css styling gia to cancel button, wste na emfanizetai panw apo to preview element
    cancelBtn.onclick = cancelUpload; // otan kanw click sto cancel button kalw tin cancelUpload function
    element.appendChild(cancelBtn); // kanw append to to cancel button sto i tou element, wste na mporw na to diagrapsw
    return element; // epistrefw to element pou kanw add sto DOM
  }

  // ean to file einai kati diaforetiko apo video h audio, h den einai supported video h audio type
  // px. enas xrhsths den kanei recording alla prospathei na anevasei ena arxeio sto file_field tou message form
  // ean to arxeio den anhkei sta file types pou orizw stin createPreviewElement, dhmiourgw element pou dhlwnei oti to arxeio den einai supported
  notSupportedPreview(cancelUpload) { 
    let cancelBtn, element;
    element = document.createElement("i");
    element.classList.add(
      "bi",
      "bi-file-earmark-x"
    );
    cancelBtn = document.createElement("i");
    cancelBtn.classList.add(
      "bi",
      "bi-trash-fill",
      "cancel-btn"
    );
    cancelBtn.onclick = cancelUpload;
    element.appendChild(cancelBtn);
    return element;
  }

  // afairw to preview element pou epilegw
  // dhmiourgw mia nea lista files mesw tou DataTransfer, kanwntas filter out to file to opoio exw epileksei na diagrapsw
  // pernaw ta files tou dataTransfer list, stin fileList tou input field tou message form, allazontas tin me ta ananewmena files pou den periexoun auto pou diegrapsa
  removeElementPreview(event) {
    //  recording-preview einai to css class kathe element
    // epeidh den mporw na to parw mesw enos div h icon, kanw target sygkekrimena to kontinotero ekswteriko element pou exei to class recording-preview panw tou
    const target = event.target.parentNode.closest(".recording-preview"); // pairnw to kontinotero parentNode tou recording-preview
    // den mporw na allaksw apeutheias tin file list tou message form stin opoia prosthetw ta recordings ws attachments
    const dataTransfer = new DataTransfer();  // kanw create ena DataTransfer,  wste na dhmiourghsw ena neo fileList
    let fileInput = document.getElementById("message_recordings");  // dhmiourgw ena fileInput to opoio pairnei to element message_recordings, pou einai to id tou file_field sti forma kai periexei ta files pou thelw na kanw upload
    let files = fileInput.files; // file list, ta files pou exoun epilegei sto file_field input
    // epeidh den mporw na kanw edit auth th lista kai thelw na afairesw ena preview file apo authn otan kanw click sto cancelBtn, prepei na ftiaksw enan Array apo auth th lista
    let filesArray = Array.from(files); // dhmiourgw pinaka apo ti lista twn files

    // den mporw na kanw write sti lista me ta files, opote den mporw na kanw assign ton array sti lista me ta files
    // ston pinaka me ti lista twn files mporw na kanw filter gia to file pou exw kanei click na diagrapsw
    filesArray = filesArray.filter((file) => {  // filter out the file by the filename
      let filename = target.dataset.filename;  // gia na parw to file pou kanw click, xrhsimopoiw to target pou exw orisei parapanw, kai pairnw to filename tou mesw tou dataset
      return file.name !== filename; // an den tairiazoun kanw return, wste na parw telika to file sto opoio exw kanei click
    });
    target.parentNode.removeChild(target);  // diagrafw to child tou parentNode tou target 
    filesArray.forEach((file) => dataTransfer.items.add(file)); // pernaw ta ypoloipa files tou array sto dataTrasfer list pou dhmiourghsa parapanw
    fileInput.files = dataTransfer.files; // allazw ti lista tou file_field input tis message form, wste na periexei ta files tou dataTransfer 

    if (filesArray.length === 0) {  // elegxw an yparxoyn files sto input field tis formas
      this.showOrHidePreviewContainer(); // an den yparxoun, kanw hide ton container twn previews
    }
  }

  // Kanei clear ta preview elements tou container meta to submit tou message form
  resetPreviews() {
    document.getElementById("preview-recordings").innerHTML = ""; // kanw empty to html content tou preview container "preview-recordings"
    let previewContainer = document.getElementById("preview-recordings");  // pairnw ton container twn previews apo to id tou
    previewContainer.classList.add("d-none");  // ton kanw hide
  }

  // gia to recording part xrhsimopoiw to Media Streams API
  // https://developer.mozilla.org/en-US/docs/Web/API/Media_Streams_API
  // https://developer.mozilla.org/en-US/docs/Web/API/MediaStream_Recording_API/Using_the_MediaStream_Recording_API

  recordVideo() {
    let recordBtn = document.getElementById("record-video-btn");  // pernaw to content_tag me id "record-video-btn", pou einai to button me to opoio ksekinaw kai stamataw to recording
    let messageRecordings = document.getElementById("message_recordings"); // grab the id tou active storage file_field tou message form sto opoio thelw na perasw to recording san video file
    // arxika den kanw kapoio recording
    let recording = false; // opote kanw record tha thetw to boolean recording se true

    if (navigator.mediaDevices.getUserMedia) {  // gia na kanw record audio h video h kai ta duo
      const constraints = { video: true, audio: true }; // thetw kai ta duo true gia na kanw record video me hxo apo to mic
      let chunks = [];  // to recording apoteleitai apo mikra chunks, apo ta opoia tha dhmiourghsw to blob

      // Elegxw an o browser mporei na yposthriksei arxeia typou "video/webm;codecs=vp9"
      // O logos pou kanw auto ton elegxo kai kanw construct ton MediaRecorder me duo tropous einai o ekshs:
      // Otan ekana recording ston Chrome me videoType "video/webm" o Firefox den mporouse na anagnwrisei to arxeio kai na kanei swsta to playback.
      // Otan ekana recording ston Chrome me to idio videoType, ta video epaizan kanonika kai stous duo browsers
      // Etsi gia na anagnwrizei o Firefox ta recordings tou Chrome, diapistwsa pws an enas browser yposthrizei recording tis morfhs "video/webm;codecs=vp9", tha kanw recordign me auto ton typo wste na anagnwrizetai apo ton Firefox
      // An den to yposthrizei (px. o Firefox), kanw ta recordings me th morfh "video/webm"
      const canRecordVp9 = MediaRecorder.isTypeSupported('video/webm;codecs=vp9');  
      let onSuccess = function (stream) { // to stream pou pernaw ston MediaRecorder
        let mediaRecorder;
        if (canRecordVp9) { // kanw construct ton MediaRecorder analoga me to ti type recording yposthrizei kathe browser
          mediaRecorder = new MediaRecorder(stream, {mimeType : 'video/webm;codecs=vp9'}); // pernaw to stream se ena MediaRecorder object, wste to stream na einai etoimo na ginei captured se ena Blob
        } else {
          mediaRecorder = new MediaRecorder(stream);  // pernaw to stream se ena MediaRecorder object, wste to stream na einai etoimo na ginei captured se ena Blob
        }
        
        recordBtn.onclick = function (event) { // pairnw to record button mesw tou id tou, kai otan ginetai click ektelw ta parakatw
          event.preventDefault(); // stops form from submitting
          if (recording) {  // elegxw an kanw video recording, wste na to stamathsw, alliws na ksekinhsw kainourio
            mediaRecorder.stop(); // an hdh kanw recording kai kanw click to record button, thelw na stamathsw to recording
            recordBtn.style.color = ""; // epanaferw to color tou record btn sto arxiko, pou dhlwnei oti den kanw recording
          } else {  // an den kanw recording hdh
            mediaRecorder.start(); // ksekinaw na kanw record to stream
            recordBtn.style.color = "red"; // allazw to color tou record btn se kokkino, gia na fainetai oti kanei recording
          }
          recording = !recording;  // meta to if statement, kanw invert to boolean recording, wste na antikatoptrizei ti nea katastash
        };

        mediaRecorder.onstop = function (event) {// otan stamathsw na kanw record, exw ena stop event, sto opoio vazw enan event handler me th xrhsh ths onstop
          let videoType;  // kathorizw to video type tou recording
          if (canRecordVp9) { // opws kai me ton MediaRecorder prohgoumenws, analogws to type pou einai supported apo ton browser
            videoType = 'video/webm;codecs=vp9';
          } else {
            videoType = 'video/webm';
          }
          //const videoType = 'video/webm;codecs=vp9';  // kathorizw to video type tou recording
          const blob = new Blob(chunks, { type: videoType });  // dhmiourgw to blob pernwntas ta recorded chunks(sta opoia exw perasei ta available data kata to recording) kai ton typo tou video
          chunks = []; // kanw reset ta chunk se empty array, wste na mhn pairnw thn idia plhroforia otan kanw neo recording

          let file = new File([blob], "video-recording.webm", { type: videoType, lastModified: new Date().getTime(), });  // dhmiourgw ena file pernwntas to blob mesa se ena array, to onoma tou arxeiou, ton typo kai to pedio lastModified
          let dataTransfer = new DataTransfer();  // dhmiourgw ena neo DataTransfer
          dataTransfer.items.add(file); // thelw mesa se auto to object na kanw add kapoia items kai pernaw to file to opoio molis dhmiourghsa
          messageRecordings.files = dataTransfer.files;   // pairnw to active storage file_field "messageRecordings" kai tou pernaw ta files tou dataTransfer pou dhmiourghsa
          messageRecordings.dispatchEvent(new Event("change"));  // kalw tin dispatchEvent change, giati exw allaksei tin forma, kai exw kapoious listeners pou otan kanw change ti form, kalei tin preview() wste na kanei preview ta files prin tin kanw submit
        };
        // oso kanw record to video, thelw na kanw collect ta video data. 
        // mesw enos event xrhsimopoiwntas thn ondataavailable pernaw data mesa sta chunks, mesw twn opoiwn tha dhmiourghsw to teliko blob tou video
        mediaRecorder.ondataavailable = function (e) {  // ston mediaRecorder an exw available data ta pernaw sta chunks
          chunks.push(e.data);
        };
      };
      let onError = function (err) {
        console.log("The following error occured: " + err);
      };

      navigator.mediaDevices.getUserMedia(constraints).then(onSuccess, onError); // kanw record to video kai epeita kalw tin onSuccess h onError
    } else {
      console.log("getUserMedia not supported on your browser!");
    }
  }

  recordAudio() {
    let recordBtn = document.getElementById("record-audio-btn");
    let messageRecordings = document.getElementById("message_recordings"); // grab the id tou active storage file_field tou message form sto opoio thelw na perasw to recording san audio file

    let recording = false; // opote kanw record tha to thetw se true

    if (navigator.mediaDevices.getUserMedia) {  // gia na kanw record audio h video h kai ta duo
      const constraints = { audio: true, video: false }; // thetw to audio true kai to video false, wste na kanw record mono to mic
      let chunks = [];  // to recording apoteleitai apo mikra chunks, apo ta opoia tha dhmiourghsw to blob

      let onSuccess = function (stream) {
        const mediaRecorder = new MediaRecorder(stream); // pernaw to stream se ena MediaRecorder object, wste to stream na einai etoimo na ginei captured se ena Blob
        recordBtn.onclick = function (event) { // pairnw to record button mesw tou id tou, kai otan kanw click se auto 
          event.preventDefault(); // stops form from submitting
          if (recording) {  // elegxw an kanw audio recording, wste na to stamathsw, alliws na ksekinhsw kainourio
            mediaRecorder.stop(); // an hdh kanw recording kai kanw click to record button, thelw na stamathsw to recording
            recordBtn.style.color = ""; // epanaferw to color tou record btn sto arxiko, pou dhlwnei oti den kanw recording
          } else {  // an den kanw recording hdh
            mediaRecorder.start(); // ksekinaw na kanw record to stream
            recordBtn.style.color = "red"; // allazw to color tou record btn se kokkino, gia na fainetai oti kanei recording
          }
          recording = !recording;  // meta to if statement, kanw invert to boolean recording, wste na antikatoptrizei ti nea katastash
        };

        mediaRecorder.onstop = function (event) {// otan stamathsw na kanw record, exw ena stop event, sto opoio vazw enan event handler me th xrhsh ths onstop
          const audioType = 'audio/ogg; codecs=opus';  // kathorizw to audio type tou recording
          const blob = new Blob(chunks, { type: audioType });  // dhmiourgw to blob pernwntas ta recorded chunks(sta opoia exw perasei ta available data kata to recording) kai ton typo tou audio
          chunks = []; // kanw reset ta chunk se empty array, wste na mhn pairnw thn idia plhroforia otan kanw neo recording

          let file = new File([blob], "audio-recording.ogg", { type: audioType, lastModified: new Date().getTime(), });  // dhmiourgw ena file pernwntas to blob mesa se ena array, to onoma tou arxeiou, ton typo kai to pedio lastModified
          let dataTransfer = new DataTransfer();  // dhmiourgw ena neo DataTransfer
          dataTransfer.items.add(file); // pernaw ston container dataTransfer to file pou molis dhmiourghsa
          messageRecordings.files = dataTransfer.files;   // pairnw to active storage file_field "messageRecordings" kai tou pernaw ta files tou dataTranfer container pou dhmiourghsa
          messageRecordings.dispatchEvent(new Event("change"));  // kalw tin dispatchEvent change, giati exw allaksei tin forma, kai exw kapoious listeners pou otan kanw change ti form, kalei tin preview() wste na kanei preview ta files prin tin kanw submit
        };
        // oso kanw record to audio, thelw na kanw collect ta audio data. 
        // mesw enos event xrhsimopoiwntas thn ondataavailable pernaw data mesa sta chunks, mesw twn opoiwn tha dhmiourghsw to teliko blob tou audio
        mediaRecorder.ondataavailable = function (e) {  // ston mediaRecorder an exw available data ta pernaw sta chunks
          chunks.push(e.data);
        };
      };
      let onError = function (err) {
        console.log("The following error occured: " + err);
      };

      navigator.mediaDevices.getUserMedia(constraints).then(onSuccess, onError); // kanw record to audio kai epeita kalw tin onSuccess h onError
    } else {
      console.log("getUserMedia not supported on your browser!");
    }
  }
}