const MessagesList = {
  mounted() {
    this.el.scrollTop = this.el.scrollHeight;

    this.canLoadMore = true;

    this.el.addEventListener("scroll", () => {
      if (this.el.scrollTop < 100 && this.canLoadMore) {
        this.canLoadMore = false;
        const prevHeight = this.el.scrollHeight;
        this.pushEvent("load-more", {}, (reply) => {
          this.el.scrollTo(0, this.el.scrollHeight - prevHeight);
          this.canLoadMore = reply.has_more_pages;
        });
      }
    });

    this.handleEvent("reset_autoscroll", (reply) => {
      this.canLoadMore = reply.has_more_pages;
    })
  },
  updated() {
    this.el.scrollTop = this.el.scrollHeight;
  }
};

export default MessagesList;
