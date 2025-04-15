import { PerfectCursor } from "../../vendor/perfect-cursors";

const CursorHook = {
  perfectCursors: {},
  cursorElements: {},

  mounted() {
    this.perfectCursors = {};
    this.cursorElements = {};
    console.log("CursorHook mounted on", this.el);

    const handleMouseMove = (e) => {
      const x = e.pageX;
      const y = e.pageY;
      this.pushEvent('cursor_move', { x, y });
    };

    this.boundMouseMove = handleMouseMove.bind(this);
    document.addEventListener('mousemove', this.boundMouseMove);

    this.handleEvent("update_cursors", (payload) => {
      const serverCursors = payload.cursors;
      const receivedUserIds = new Set();

      serverCursors.forEach(cursor => {
        const { user_id, x, y } = cursor;
        receivedUserIds.add(user_id.toString());

        let pc = this.perfectCursors[user_id];
        let el = this.cursorElements[user_id];

        if (!el) {
            el = this.el.querySelector(`#cursor-${user_id}`);
            if (el) {
                this.cursorElements[user_id] = el;
            }
        }

        if (el) {
          if (!pc) {
            const cursorElement = el;
            pc = new PerfectCursor((point) => {
              cursorElement.style.transform = `translate(${point.x}px, ${point.y}px)`;
            });
            this.perfectCursors[user_id] = pc;
          }
          pc.addPoint([x, y]);
        }
      });

      Object.keys(this.perfectCursors).forEach(userIdStr => {
        if (!receivedUserIds.has(userIdStr)) {
          this.perfectCursors[userIdStr].dispose();
          delete this.perfectCursors[userIdStr];
          delete this.cursorElements[userIdStr];
        }
      });
    });
  },

  destroyed() {
    if (this.boundMouseMove) {
      document.removeEventListener('mousemove', this.boundMouseMove);
    }
    Object.values(this.perfectCursors).forEach(pc => pc.dispose());
    this.perfectCursors = {};
    this.cursorElements = {};
    console.log("CursorHook destroyed");
  },
};

export default CursorHook;
