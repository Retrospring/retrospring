import Rails from '@rails/ujs';
import swal from 'sweetalert';

import I18n from '../../../i18n';
import { updateDeleteButton } from '../delete';
import animate from '../../../utilities/animate';
import { showNotification, showErrorNotification } from '../../../utilities/notifications';

export function deleteEntryHandler(event: Event): void {
  const element: HTMLButtonElement = event.currentTarget as HTMLButtonElement;

  const data = {
    id: element.getAttribute('data-ib-id')
  };

  swal({
    title: I18n.t('frontend.inbox.confirm.title'),
    text: I18n.t('frontend.inbox.confirm.text'),
    icon: 'warning',
    dangerMode: true,
    buttons: [
      I18n.t('views.actions.cancel'),
      I18n.t('views.actions.delete')
    ]
  })
  .then((returnValue) => {
    if (returnValue === null) return false;
    
    Rails.ajax({
      url: '/ajax/delete_inbox',
      type: 'POST',
      data: new URLSearchParams(data).toString(),
      success: (data) => {
        if (!data.success) return false;
        const inboxEntry: Node = element.closest('.inbox-entry');
        updateDeleteButton(false);
        showNotification(data.message);

        animate(inboxEntry, 'fadeOutUp')
          .then(() => {
            (inboxEntry as HTMLElement).remove();
          });
      },
      error: (data, status, xhr) => {
        console.log(data, status, xhr);
        showErrorNotification(I18n.t('frontend.error.message'));
      }
    });
  })
}
