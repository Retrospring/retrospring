import { post } from '@rails/request.js';
import swal from 'sweetalert';

import I18n from 'retrospring/i18n';
import { showNotification, showErrorNotification } from 'utilities/notifications';

export function reportDialog(type: string, target: string): void {
  swal({
    title: I18n.translate('frontend.report.confirm.title', { type: type }),
    text: I18n.translate('frontend.report.confirm.text'),
    type: 'input',
    showCancelButton: true,
    confirmButtonColor: "#DD6B55",
    confirmButtonText: I18n.translate('voc.report'),
    cancelButtonText: I18n.translate('voc.cancel'),
    closeOnConfirm: true,
    inputPlaceholder: I18n.translate('frontend.report.confirm.input')
  }, (returnValue) => {
    if (returnValue === false) {
      return;
    }

    post('/ajax/report', {
      body: {
        id: String(target),
        type: type,
        reason: returnValue
      }
    }).then(async response => {
      const data = await response.json;

      showNotification(data.message, data.success);
    }).catch(e => {
      console.error("Failed to submit report", e);
      showErrorNotification(I18n.translate('frontend.error.message'));
    });
  });
}
