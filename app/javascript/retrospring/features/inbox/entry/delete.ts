import { post } from '@rails/request.js';
import swal from 'sweetalert';

import I18n from 'retrospring/i18n';
import { updateDeleteButton } from '../delete';
import { showNotification, showErrorNotification } from 'utilities/notifications';

export function deleteEntryHandler(event: Event): void {
  const element: HTMLButtonElement = event.target as HTMLButtonElement;

  const data = {
    id: element.getAttribute('data-ib-id')
  };

  swal({
    title: I18n.translate('frontend.inbox.confirm.title'),
    text: I18n.translate('frontend.inbox.confirm.text'),
    type: "warning",
    showCancelButton: true,
    confirmButtonColor: "#DD6B55",
    confirmButtonText: I18n.translate('voc.delete'),
    cancelButtonText: I18n.translate('voc.cancel'),
    closeOnConfirm: true
  }, () => {
    element.disabled = true;

    post('/ajax/delete_inbox', {
      body: data,
      contentType: 'application/json'
    })
      .then(async response => {
        const data = await response.json;

        if (!data.success) return false;
        const inboxEntry: Node = element.closest('.inbox-entry');

        updateDeleteButton(false);
        showNotification(data.message);

        (inboxEntry as HTMLElement).remove();
      })
      .catch(err => {
        element.disabled = false;
        console.log(err);
        showErrorNotification(I18n.translate('frontend.error.message'));
      });
  })
}