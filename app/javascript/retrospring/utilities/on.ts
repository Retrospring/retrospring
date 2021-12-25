export function on(type: string, selector: string, callback: Function): void {
  document.addEventListener(type, (event: Event) => {
    if ((event.target as HTMLElement).matches(selector)) {
      callback(event);
    }
  });
};