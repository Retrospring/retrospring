import {Controller} from "@hotwired/stimulus";

const INTERVALS = {
  "year": 86_400_000 * 365,
  "month": 86_400_000 * 30,
  "week": 86_400_000 * 7,
  "day": 86_400_000,
  "hour": 3_600_000,
  "minute": 60_000,
  "second": 1_000,
};

export default class extends Controller<HTMLTimeElement> {
  private formatter: Intl.RelativeTimeFormat;

  initialize(): void {
    const locale = Intl.RelativeTimeFormat.supportedLocalesOf([document.documentElement.lang, 'en'], { localeMatcher: "lookup" });
    this.formatter = new Intl.RelativeTimeFormat(locale, { numeric: 'auto', style: 'long'});
  }

  connect(): void {
    const date = new Date(this.element.dateTime);

    // convert date to timestamp by casting to number
    const now = +new Date();
    const then = +date;
    const delta = then - now;

    this.element.innerText = this.formatTime(delta);
  }

  formatTime(delta: number): string {
    for (const unit in INTERVALS) {
      const duration = INTERVALS[unit];
      const count = Math.floor(delta / duration);
      if (count < -1) {
        return this.formatter.format(count, unit as Intl.RelativeTimeFormatUnitSingular);
      }
    }

    return this.formatter.format(0, 'second');
  }
}
