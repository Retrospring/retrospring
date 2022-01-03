export function questionboxReportHandler(event: Event) {
  event.preventDefault();
  const button = event.target as HTMLButtonElement;
  const questionId = button.dataset.qId;

  window['reportDialog']('question', questionId);
}