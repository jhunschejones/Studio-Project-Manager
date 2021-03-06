import { Controller } from "stimulus"

export default class extends Controller {
  initialize() {
    // Uncomment to automatically fade out flash
    // const _this = this;
    // const target = document.querySelector(".flash");
    // setTimeout(() => {_this.fadeOut(target);}, 3500);
  }

  close(e) {
    const flash = e.target.parentNode;
    flash.parentNode.removeChild(flash);
  }

  fadeOut(target) {
    var fadeEffect = setInterval(function () {
      if (!target.style.opacity) {
        target.style.opacity = 1;
      }
      if (target.style.opacity > 0) {
        target.style.opacity -= 0.05;
      } else {
        clearInterval(fadeEffect);
        target.parentNode.removeChild(target);
      }
    }, 50);
  }
}
