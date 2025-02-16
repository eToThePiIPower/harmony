import TimeAgo from 'javascript-time-ago'
import en from 'javascript-time-ago/locale/en'
TimeAgo.addDefaultLocale(en)
const timeAgo = new TimeAgo('en-US')

const Timestamp = {
  mounted() {
    this.updateTime = () => {
      const timestamp = new Date(this.el.dataset.timestamp);
      this.el.textContent = timeAgo.format(timestamp);
    };
    this.intervalId = setInterval(this.updateTime, 1000);
    this.updateTime() // force update the inital absolute timestamps
  },
  destroyed() {
    clearInterval(this.intervalId);
  }
}

export default Timestamp;
