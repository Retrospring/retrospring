import Rails from '@rails/ujs';
import { showNotification, showErrorNotification } from 'utilities/notifications';
import I18n from 'retrospring/i18n';

export function userActionHandler(event: Event): void {
  const button: HTMLButtonElement = event.target as HTMLButtonElement;
  const target = button.dataset.target;
  const action = button.dataset.action;

  const targetURL = action === 'follow' ? '/ajax/create_relationship' : '/ajax/destroy_relationship';
  let success = false;

  Rails.ajax({
    url: targetURL,
    type: 'POST',
    data: new URLSearchParams({
      screen_name: target,
      type: "follow"
    }).toString(),
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

      switch (action) {
        case 'follow':
          button.dataset.action = 'unfollow';
          button.innerText = I18n.translate('views.actions.unfollow');
          button.classList.remove('btn-primary');
          button.classList.add('btn-default');
          break;
        case 'unfollow':
          button.dataset.action = 'follow';
          button.innerText = I18n.translate('views.actions.follow');
          button.classList.remove('btn-default');
          button.classList.add('btn-primary');
          break;
      }
     }
  });
}