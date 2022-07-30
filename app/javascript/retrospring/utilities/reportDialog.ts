import Rails from '@rails/ujs';
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
    
    Rails.ajax({
      url: '/ajax/report',
      type: 'POST',
      data: new URLSearchParams({
        id: String(target),
        type: type,
        reason: returnValue
      }).toString(),
      success: (data) => {
        showNotification(data.message);
      },
      error: (data, status, xhr) => {
        console.log(data, status, xhr);
        showErrorNotification(I18n.translate('frontend.error.message'));
      }
    });
  });
}