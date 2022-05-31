// megalwnw to height tis comment form otan pataw enter wste na einai pio eukolo na grapsw comment
// kai na mhn kryvetai to mhnyma stin forma kai xreiazetai scroll gia na diavastei swsta
import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
    static targets = [ "input" ]

    connect() {
        console.log('auto-grow-textarea controller connected...');
        this.inputTarget.style.resize = 'none';
        this.inputTarget.style.minHeight = `${this.inputTarget.scrollHeight}px`;
        this.inputTarget.style.overflow = 'hidden';
    }

    resize(event){
        event.target.style.height = '46px';
        event.target.style.height =  `${event.target.scrollHeight}px`;
    }

}