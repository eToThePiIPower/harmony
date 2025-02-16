const Timestamp = {
  mounted() {
    this.updateTime = () => {
      const now = new Date();
      const timestamp = new Date(this.el.dataset.timestamp);
      this.el.textContent = timeAgo(now, timestamp);
    };
    this.intervalId = setInterval(this.updateTime, 1000);
    this.updateTime() // force update the inital absolute timestamps
  },
  destroyed() {
    clearInterval(this.intervalId);
  }
}

timeAgo = (now, then) => {
  var seconds = Math.floor((now - then) / 1000);

  var interval = seconds;
  if (interval < 10) {
    return "now";
  }
  if (interval < 60) {
    return "less than a minute ago";
  }

  interval = seconds / 60;
  if (interval < 2) {
    return "a minute ago";
  }
  if (interval < 75) {
    return Math.floor(interval) + " minutes ago";
  }

  interval = seconds / 3600;
  if (interval < 2) {
    return "an hour ago";
  }
  if (interval < 30) {
    return Math.floor(interval) + " hours ago";
  }

  interval = seconds / 86400;
  if (interval < 2) {
    return "a day ago";
  }
  if (interval < 38) {
    return Math.floor(interval) + " days ago";
  }

  interval = seconds / 2592000;
  if (interval < 2) {
    return "a month ago";
  }
  if (interval < 13) {
    return Math.floor(interval) + " months ago";
  }

  interval = seconds / 31536000;
  if (interval < 2) {
    return "a year ago";
  }
  return Math.floor(interval) + " years ago";
}

export default Timestamp;
