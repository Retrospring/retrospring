import Rails from '@rails/ujs';
import { showNotification, showErrorNotification } from 'utilities/notifications';
import I18n from 'retrospring/i18n';

export function userActionHandler(event: Event): void {
  event.preventDefault();
  const button: HTMLButtonElement = event.target as HTMLButtonElement;
  const target = button.dataset.target;
  const action = button.dataset.action;

  let targetURL, relationshipType;

  switch (action) {
    case 'follow':
      targetURL = '/ajax/create_relationship';
      relationshipType = 'follow';
      break;
    case 'unfollow':
      targetURL = '/ajax/destroy_relationship';
      relationshipType = 'follow';
      break;
    case 'block':
      targetURL = '/ajax/create_relationship';
      relationshipType = 'block';
      break;
    case 'unblock':
      targetURL = '/ajax/destroy_relationship';
      relationshipType = 'block';
      break;
  }
  let success = false;

  Rails.ajax({
    url: targetURL,
    type: 'POST',
    data: new URLSearchParams({
      screen_name: target,
      type: relationshipType,
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
        case 'block':
          button.dataset.action = 'unblock';
          button.querySelector('span').innerText = I18n.translate('views.actions.unblock');
          button.classList.remove('btn-primary');
          button.classList.add('btn-default');
          break;
        case 'unblock':
          button.dataset.action = 'block';
          button.querySelector('span').innerText = I18n.translate('views.actions.block');
          button.classList.remove('btn-default');
          button.classList.add('btn-primary');
          break;
      }
     }
  });
}