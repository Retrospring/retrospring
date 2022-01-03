import Rails from '@rails/ujs';
import swal from 'sweetalert';

import I18n from '../../../legacy/i18n';
import { showErrorNotification } from 'utilities/notifications';

export function updateDeleteButton(increment = true): void {
  const deleteButton: HTMLElement = document.querySelector('[id^=ib-delete-all]');
  const inboxCount: number = parseInt(deleteButton.getAttribute('data-ib-count'));
  let targetInboxCount = 0;

  if (increment) {
    targetInboxCount = inboxCount + 1;
  }
  else {
    targetInboxCount = inboxCount - 1;
  }

  deleteButton.setAttribute('data-ib-count', targetInboxCount.toString());

  if (targetInboxCount > 0) {
    deleteButton.removeAttribute('disabled');
  } else {
    deleteButton.setAttribute('disabled', 'disabled');
  }
}

export function deleteAllQuestionsHandler(event: Event): void {
  const button = event.target as Element;
  const count = button.getAttribute('data-ib-count');

  swal({
    title: I18n.t('frontend.inbox.confirm_all.title', { count: count }),
    text: I18n.t('frontend.inbox.confirm_all.text'),
    icon: 'warning',
    dangerMode: true,
    buttons: [
      I18n.t('views.actions.cancel'),
      I18n.t('views.actions.delete')
    ]
  }, (returnValue) => {
    if (returnValue === null) return false;
    
    Rails.ajax({
      url: '/ajax/delete_all_inbox',
      type: 'POST',
      dataType: 'json',
      success: (data) => {
        if (!data.success) return false;

        updateDeleteButton(false);
        document.querySelector('#entries').innerHTML = 'Nothing to see here!';
      },
      error: (data, status, xhr) => {
        console.log(data, status, xhr);
        showErrorNotification(I18n.t('frontend.error.message'));
      }
    });
  });
}

export function deleteAllAuthorQuestionsHandler(event: Event): void {
  const button = event.target as Element;
  const count = button.getAttribute('data-ib-count');

  swal({
    title: I18n.t('frontend.inbox.confirm_all.title', { count: count }),
    text: I18n.t('frontend.inbox.confirm_all.text'),
    icon: 'warning',
    dangerMode: true,
    buttons: [
      I18n.t('views.actions.cancel'),
      I18n.t('views.actions.delete')
    ]
  }, (returnValue) => {
    if (returnValue === null) return false;
    
    Rails.ajax({
      url: `/ajax/delete_all_inbox/${location.pathname.split('/')[2]}`,
      type: 'POST',
      dataType: 'json',
      success: (data) => {
        if (!data.success) return false;

        updateDeleteButton(false);
        document.querySelector('#entries').innerHTML = 'Nothing to see here!';
      },
      error: (data, status, xhr) => {
        console.log(data, status, xhr);
        showErrorNotification(I18n.t('frontend.error.message'));
      }
    });
  });
}