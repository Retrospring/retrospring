import Rails from '@rails/ujs';
import swal from 'sweetalert';

import I18n from 'retrospring/i18n';
import { showNotification, showErrorNotification } from 'utilities/notifications';

export function destroyReportHandler(event: Event): void {
  const button = event.target as HTMLButtonElement;
  const id = button.dataset.id;

  swal({
    title: I18n.translate('frontend.destroy_report.confirm.title'),
    text: I18n.translate('frontend.destroy_report.confirm.text'),
    type: "warning",
    showCancelButton: true,
    confirmButtonColor: "#DD6B55",
    confirmButtonText: I18n.translate('voc.delete'),
    cancelButtonText: I18n.translate('voc.cancel'),
    closeOnConfirm: true
  }, () => {
    Rails.ajax({
      url: '/ajax/mod/destroy_report',
      type: 'POST',
      data: new URLSearchParams({
        id: id
      }).toString(),
      success: (data) => {
        if (data.success) {
          document.querySelector(`.moderationbox[data-id="${id}"]`).remove();
        }
        showNotification(data.message, data.success);
      },
      error: (data, status, xhr) => {
        console.log(data, status, xhr);
        showErrorNotification(I18n.translate('frontend.error.message'));
      }
    });
  });
}