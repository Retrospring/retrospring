import { install } from '@github/hotkey'

export default function (): void {
  document.addEventListener('turbo:load', () => {
    console.debug("Init Hotkey.")
    document.querySelectorAll('[data-hotkey]').forEach(el => install(el as HTMLElement));
  });
}
