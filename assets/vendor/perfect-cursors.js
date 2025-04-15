// src/point.ts
function dist(a, b) {
  return Math.hypot(a[1] - b[1], a[0] - b[0]);
}

// src/spline.ts
var Spline = class {
  constructor(points = []) {
    this.points = [];
    this.lengths = [];
    this.totalLength = 0;
    this.addPoint = (point) => {
      if (this.prev) {
        const length = dist(this.prev, point);
        this.lengths.push(length);
        this.totalLength += length;
        this.points.push(point);
      }
      this.prev = point;
    };
    this.clear = () => {
      this.points = this.prev ? [this.prev] : [];
      this.totalLength = 0;
    };
    this.getSplinePoint = (rt) => {
      const { points } = this;
      const l = points.length - 1, d = Math.trunc(rt), p1 = Math.min(d + 1, l), p2 = Math.min(p1 + 1, l), p3 = Math.min(p2 + 1, l), p0 = p1 - 1, t = rt - d;
      const tt = t * t, ttt = tt * t, q1 = -ttt + 2 * tt - t, q2 = 3 * ttt - 5 * tt + 2, q3 = -3 * ttt + 4 * tt + t, q4 = ttt - tt;
      const [p0x, p0y] = points[p0], [p1x, p1y] = points[p1], [p2x, p2y] = points[p2], [p3x, p3y] = points[p3];
      return [
        (p0x * q1 + p1x * q2 + p2x * q3 + p3x * q4) / 2,
        (p0y * q1 + p1y * q2 + p2y * q3 + p3y * q4) / 2
      ];
    };
    this.points = points;
    this.lengths = points.map((point, i, arr) => i === 0 ? 0 : dist(point, arr[i - 1]));
    this.totalLength = this.lengths.reduce((acc, cur) => acc + cur, 0);
  }
};

// src/perfect-cursor.ts
var _PerfectCursor = class {
  constructor(cb) {
    this.state = "idle";
    this.queue = [];
    this.timestamp = performance.now();
    this.lastRequestId = 0;
    this.timeoutId = null;
    this.spline = new Spline();
    this.addPoint = (point) => {
      if (this.timeoutId)
        clearTimeout(this.timeoutId);
      const now = performance.now();
      const duration = Math.min(now - this.timestamp, _PerfectCursor.MAX_INTERVAL);
      if (!this.prevPoint) {
        this.spline.clear();
        this.prevPoint = point;
        this.spline.addPoint(point);
        this.cb(point);
        this.state = "stopped";
        return;
      }
      if (this.state === "stopped") {
        if (dist(this.prevPoint, point) < 4) {
          this.cb(point);
          return;
        }
        this.spline.clear();
        this.spline.addPoint(this.prevPoint);
        this.spline.addPoint(this.prevPoint);
        this.spline.addPoint(point);
        this.state = "idle";
      } else {
        this.spline.addPoint(point);
      }
      if (duration < 16) {
        this.prevPoint = point;
        this.timestamp = now;
        this.cb(point);
        return;
      }
      const animation = {
        start: this.spline.points.length - 3,
        from: this.prevPoint,
        to: point,
        duration
      };
      this.prevPoint = point;
      this.timestamp = now;
      switch (this.state) {
        case "idle": {
          this.state = "animating";
          this.animateNext(animation);
          break;
        }
        case "animating": {
          this.queue.push(animation);
          break;
        }
      }
    };
    this.animateNext = (animation) => {
      const start = performance.now();
      const loop = () => {
        const t = (performance.now() - start) / animation.duration;
        if (t <= 1 && this.spline.points.length > 0) {
          try {
            this.cb(this.spline.getSplinePoint(t + animation.start));
          } catch (e) {
            console.warn(e);
          }
          this.lastRequestId = requestAnimationFrame(loop);
          return;
        }
        const next = this.queue.shift();
        if (next) {
          this.state = "animating";
          this.animateNext(next);
        } else {
          this.state = "idle";
          this.timeoutId = setTimeout(() => {
            this.state = "stopped";
          }, _PerfectCursor.MAX_INTERVAL);
        }
      };
      loop();
    };
    this.dispose = () => {
      if (this.timeoutId)
        clearTimeout(this.timeoutId);
    };
    this.cb = cb;
  }
};
var PerfectCursor = _PerfectCursor;
PerfectCursor.MAX_INTERVAL = 300;
export {
  PerfectCursor
};
//# sourceMappingURL=index.js.map
