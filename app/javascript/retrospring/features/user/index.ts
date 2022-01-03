import { userActionHandler } from './action';
import { userReportHandler } from './report';
import registerEvents from 'retrospring/utilities/registerEvents';

export default (): void => {
  registerEvents([
    { type: 'click', target: 'button[name=user-action]', handler: userActionHandler, global: true },
    { type: 'click', target: 'a[data-action=report-user]', handler: userReportHandler, global: true }
  ]);
}