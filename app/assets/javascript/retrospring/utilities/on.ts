export type OnCallbackFunction = (event: Event) => void;

export function on(type: string, selector: string, callback: OnCallbackFunction): void {
  document.addEventListener(type, (event: Event) => {
    if ((event.target as HTMLElement).matches(selector)) {
      callback(event);
    }
  });
}