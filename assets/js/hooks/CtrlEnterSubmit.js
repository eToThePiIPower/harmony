const CtrlEnterSubmit = {
  mounted() {
    this.el.addEventListener('keydown', e => {
      if (e.ctrlKey && e.key === 'Enter') {
        this.el.dispatchEvent(new Event("change", {bubbles: true, cancelable: true}));
        this.el.form.dispatchEvent(new Event("submit", {bubbles: true, cancelable: true}));
      }
    });
  }
};

export default CtrlEnterSubmit;
