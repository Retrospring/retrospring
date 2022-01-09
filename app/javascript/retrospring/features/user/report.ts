import { reportDialog } from 'utilities/reportDialog';

export function userReportHandler(event: Event): void {
  event.preventDefault();
  const button: HTMLButtonElement = event.target as HTMLButtonElement;

  reportDialog('user', button.dataset.target);
}