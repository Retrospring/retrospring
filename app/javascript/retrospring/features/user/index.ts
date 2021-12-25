import { userActionHandler } from './action';
import { userReportHandler } from './report';
import { on } from 'utilities/on';

export default (): void => {
  on('click', 'button[name=user-action]', userActionHandler);
  on('click', 'a[data-action=report-user]', userReportHandler);
}