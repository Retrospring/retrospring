import { reportDialog } from 'utilities/reportDialog';

export function commentReportHandler(event: Event): void {
  event.preventDefault();
  const button = event.target as HTMLButtonElement;
  const commentId = button.dataset.cId;

  reportDialog('comment', commentId);
}