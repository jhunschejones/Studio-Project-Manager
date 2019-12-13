import { Controller } from "stimulus"

const LEAVING_PAGE_MESSAGE = "You have attempted to leave this page and you are uploading files. If you leave, you will need to reupload these files. Are you sure you want to exit this page?"

export default class extends Controller {

  startDirectUploads(event) {
    this.setUploading("true")
  }

  endDirectUploads(event) {
    this.setUploading("false")
  }

  leavingPage(event) {
    if (this.isUploadingFiles()) {
      if (event.type == "turbolinks:before-visit") {
        if (!window.confirm(LEAVING_PAGE_MESSAGE)) {
          event.preventDefault()
        }
      } else {
        event.returnValue = LEAVING_PAGE_MESSAGE;
        return event.returnValue;
      }
    }
  }

  setUploading(changed) {
    this.data.set("uploading", changed)
  }

  isUploadingFiles() {
    return this.data.get("uploading") == "true";
  }
}
