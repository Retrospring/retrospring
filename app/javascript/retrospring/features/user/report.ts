export function userReportHandler(event: Event): void {
  event.preventDefault();
  const button: HTMLButtonElement = event.target as HTMLButtonElement;

  window['reportDialog']('user', button.dataset.target);
}