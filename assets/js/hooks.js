let Hooks = {}

Hooks.FeedNav = {
  mounted() {
    const live = this;

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

    this.handleKeyDown = handleKeyDown;

    window.addEventListener("keydown", handleKeyDown);
  },
   destroyed() {
    window.removeEventListener("keydown", this.handleKeyDown);
  },
  currentIndex() {
    const active = document.querySelector("#feed");
    console.log(active);
    if (!active) return 0;
    return parseInt(active.getAttribute("data-active"), 10);
  }
}

export default Hooks;
