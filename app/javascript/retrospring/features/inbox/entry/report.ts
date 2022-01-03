export function reportEventHandler(event: Event): void {
  const element = event.target as HTMLElement;
  window['reportDialog']('question', element.dataset.qId);
}