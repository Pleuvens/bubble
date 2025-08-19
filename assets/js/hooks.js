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

export default Hooks;
