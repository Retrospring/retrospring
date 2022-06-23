import Rails from '@rails/ujs';
import { showNotification, showErrorNotification } from 'utilities/notifications';
import I18n from 'retrospring/i18n';

export function unblockAnonymousHandler(event: Event): void {
  const button: HTMLButtonElement = event.currentTarget as HTMLButtonElement;
  const targetId = button.dataset.target;
  let success = false;

  Rails.ajax({
    url: `/ajax/block_anon/${targetId}`,
    type: 'DELETE',
    success: (data) => {
      success = data.success;
      showNotification(data.message, data.success);
    },
    error: (data, status, xhr) => {
      console.log(data, status, xhr);
      showErrorNotification(I18n.translate('frontend.error.message'));
    },
    complete: () => {
      if (!success) return;

      button.closest('.list-group-item').remove();
     }
  });
}