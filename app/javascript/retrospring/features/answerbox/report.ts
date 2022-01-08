export function answerboxReportHandler(event: Event): void {
  event.preventDefault();
  const button = event.target as HTMLButtonElement;
  const answerId = button.dataset.aId;

  window['reportDialog']('answer', answerId);
}