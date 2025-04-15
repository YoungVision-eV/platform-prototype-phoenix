// assets/js/hooks/cursor_hook.js
const CursorHook = {
  mounted() {
    this.throttleMs = 50; // Send updates every 50ms
    this.cursorTimeout = null;
    this.lastSent = { x: -1, y: -1 }; // Track last sent position

    this.boundMouseMove = (e) => {
      // Only push if the timeout isn't active
      if (!this.cursorTimeout) {
        const x = e.pageX;
        const y = e.pageY;

        // Only send if position actually changed significantly (optional optimization)
        if (Math.abs(this.lastSent.x - x) > 1 || Math.abs(this.lastSent.y - y) > 1) {
            this.pushEvent("cursor_move", { x: x, y: y });
            this.lastSent = { x, y }; // Update last sent position

            this.cursorTimeout = setTimeout(() => {
                this.cursorTimeout = null; // Clear timeout after delay
            }, this.throttleMs);
        }
      }
    };

    window.addEventListener("mousemove", this.boundMouseMove);
  },

  destroyed() {
    window.removeEventListener("mousemove", this.boundMouseMove);
    if (this.cursorTimeout) {
      clearTimeout(this.cursorTimeout); // Clear timeout if hook is destroyed
    }
  },
};

export default CursorHook;
