import { reportDialog } from 'utilities/reportDialog';

export function reportEventHandler(event: Event): void {
  const element = event.target as HTMLElement;
  reportDialog('question', element.dataset.qId);
}