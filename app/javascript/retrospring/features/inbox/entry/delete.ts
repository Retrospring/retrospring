import Rails from '@rails/ujs';
import swal from 'sweetalert';

import I18n from 'retrospring/i18n';
import { updateDeleteButton } from '../delete';
import { showNotification, showErrorNotification } from 'utilities/notifications';

export function deleteEntryHandler(event: Event): void {
  const element: HTMLButtonElement = event.target as HTMLButtonElement;
  element.disabled = true;

  const data = {
    id: element.getAttribute('data-ib-id')
  };

  swal({
    title: I18n.translate('frontend.inbox.confirm.title'),
    text: I18n.translate('frontend.inbox.confirm.text'),
    type: "warning",
    showCancelButton: true,
    confirmButtonColor: "#DD6B55",
    confirmButtonText: I18n.translate('views.actions.delete'),
    cancelButtonText: I18n.translate('views.actions.cancel'),
    closeOnConfirm: true
  }, (returnValue) => {
    if (returnValue === false) {
      element.disabled = false;
      return;
    }
    
    Rails.ajax({
      url: '/ajax/delete_inbox',
      type: 'POST',
      data: new URLSearchParams(data).toString(),
      success: (data) => {
        if (!data.success) return false;
        const inboxEntry: Node = element.closest('.inbox-entry');

        updateDeleteButton(false);
        showNotification(data.message);

        (inboxEntry as HTMLElement).remove();
      },
      error: (data, status, xhr) => {
        console.log(data, status, xhr);
        showErrorNotification(I18n.translate('frontend.error.message'));
      }
    });
  })
}