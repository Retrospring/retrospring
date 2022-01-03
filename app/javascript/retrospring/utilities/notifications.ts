export function showErrorNotification(text: string): void {
  showNotification(text, false);
}

export function showNotification(text: string, status = true): void {
  window['showNotification'](text, status);
}