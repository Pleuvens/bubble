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
      } else if (e.key === "Enter") {
        e.preventDefault();
        const idx = live.currentIndex();
        const el = document.getElementById(`news-item-${idx}`);
        if (el) {
          const link = el.querySelector("h2 a");
          if (link) window.open(link.href, "_blank", "noopener");
        }
      }
    };

    this.handleKeyDown = handleKeyDown;
    window.addEventListener("keydown", handleKeyDown);
  },

  updated() {
    const idx = this.currentIndex();
    const el = document.getElementById(`news-item-${idx}`);
    if (el) {
      el.scrollIntoView({ behavior: "smooth", block: "nearest" });
    }
  },

  destroyed() {
    window.removeEventListener("keydown", this.handleKeyDown);
  },

  currentIndex() {
    const feed = document.querySelector("#feed");
    if (!feed) return 0;
    return parseInt(feed.getAttribute("data-active"), 10) || 0;
  }
};

export default Hooks;
