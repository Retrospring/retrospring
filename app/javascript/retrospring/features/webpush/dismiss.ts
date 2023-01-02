export function dismissHandler (event: Event): void {
  event.preventDefault();

  const sender: HTMLButtonElement = event.target as HTMLButtonElement;
  sender.closest<HTMLDivElement>('.push-settings').classList.add('d-none');
  localStorage.setItem('dismiss-push-settings-prompt', 'true');
}
