import { reportDialog } from 'utilities/reportDialog';

export function questionReportHandler(event: Event): void {
  event.preventDefault();
  const button = event.target as HTMLButtonElement;
  const questionId = button.dataset.qId;

  reportDialog('question', questionId);
}