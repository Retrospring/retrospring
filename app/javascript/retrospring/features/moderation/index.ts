import registerEvents from 'utilities/registerEvents';
import registerCommentEvents from './comment';
import { banCheckboxHandler, banFormHandler, permanentBanCheckboxHandler } from './ban';
import { destroyReportHandler } from './destroy';
import { privilegeCheckHandler } from './privilege';
import { voteReportHandler } from './vote';

export default (): void => {
  registerEvents([
    { type: 'click', target: '[name=mod-vote]', handler: voteReportHandler, global: true },
    { type: 'click', target: '[type=checkbox][name=check-your-privileges]', handler: privilegeCheckHandler, global: true },
    { type: 'click', target: '[name=mod-delete-report]', handler: destroyReportHandler, global: true },
    { type: 'change', target: '[name="ban"][type="checkbox"]', handler: banCheckboxHandler, global: true },
    { type: 'change', target: '[name="permaban"][type="checkbox"]', handler: permanentBanCheckboxHandler, global: true },
    { type: 'submit', target: '#modal-ban form', handler: banFormHandler, global: true }
  ]);

  registerCommentEvents();
}