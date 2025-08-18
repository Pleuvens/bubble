// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let Hooks = {}

Hooks.FeedNav = {
  mounted() {
    const live = this;

    let timeout

    const handleKeyDown = (e) => {
      if (["ArrowDown", "j"].includes(e.key)) {
        e.preventDefault();
        live.pushEvent("set_index", { index: live.currentIndex() + 1 });
      } else if (["ArrowUp", "k"].includes(e.key)) {
        e.preventDefault();
        live.pushEvent("set_index", { index: live.currentIndex() - 1 });
      } else if (["Enter", " "].includes(e.key)) {
        e.preventDefault();
        const idx = live.currentIndex();
        const el = document.getElementById(`news-item-${idx}`);
        if (el) {
          live.pushEvent("toggle_expanded", { });
        }
      }
    }

    const handleScroll = () => {
      const scrollY = window.scrollY;
      const viewportHeight = window.innerHeight;
      const newIndex = Math.round(scrollY / viewportHeight);
      live.pushEvent("set_index", { index: newIndex });
    };

    this.handleKeyDown = handleKeyDown;
    this.handleScroll = handleScroll;

    window.addEventListener("keydown", handleKeyDown);
    window.addEventListener("scroll", handleScroll);
  },
   destroyed() {
    window.removeEventListener("keydown", this.handleKeyDown);
    window.removeEventListener("scroll", this.handleScroll);
  },
  updated() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
    }
    this.timeoutId = setTimeout(() => {
      console.log("Scrolling to current index");
    const idx = this.currentIndex();
    const element = document.getElementById(`news-item-${idx}`);
    if (element) {
      element.scrollIntoView({ behavior: "smooth", block: "center" });
    }
    this.timeoutId = null;
    }, 800);
  },
  currentIndex() {
    const active = document.querySelector("#feed");
    console.log(active);
    if (!active) return 0;
    return parseInt(active.getAttribute("data-active"), 10);
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken}
,
  hooks: Hooks})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

