import { destroy } from '@rails/request.js';
import { showNotification, showErrorNotification } from 'utilities/notifications';
import I18n from 'retrospring/i18n';

export function unblockAnonymousHandler(event: Event): void {
  const button: HTMLButtonElement = event.currentTarget as HTMLButtonElement;
  const targetId = button.dataset.target;

  destroy(`/ajax/block_anon/${targetId}`)
    .then(async response => {
      if (!response.ok) return;

      const data = await response.json;
      showNotification(data.message, data.success);
      button.closest('.list-group-item').remove();
    })
    .catch(err => {
      console.log(err);
      showErrorNotification(I18n.translate('frontend.error.message'));
    });
}