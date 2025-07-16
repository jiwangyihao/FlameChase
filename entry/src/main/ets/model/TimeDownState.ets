export class TimeDownState {
  total: number = 0;
  timeDown: number = 0;
  started: boolean = false;
  intervalId: number | null = null;
  reject: ((reason?: string) => void) | null = null;

  get timeDownText() {
    return parseTimeText(this.timeDown);
  }

  start(total: number): Promise<void> {
    return new Promise((resolve, reject) => {
      this.total = total;
      this.reject = reject;
      this.timeDown = this.total;
      this.intervalId = setInterval(() => {
        if (this.timeDown > 0) {
          this.timeDown--;
        } else {
          this.stop();
          this.reject = null;
          resolve();
        }
      }, 1000);
      this.started = true;
    });
  }

  stop() {
    this.started = false;
    if (this.intervalId !== null) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
    if (this.reject && this.timeDown > 0) {
      this.reject("Time down stopped");
      this.reject = null;
    }
    this.timeDown = 0;
  }
}

export function parseTimeText(time: number): string {
  const minutes = Math.floor(time / 60);
  const seconds = time % 60;
  return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
}