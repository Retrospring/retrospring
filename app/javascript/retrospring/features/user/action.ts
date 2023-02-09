import { post } from '@rails/request.js';
import { showNotification, showErrorNotification } from 'utilities/notifications';
import I18n from 'retrospring/i18n';

export function userActionHandler(event: Event): void {
  event.preventDefault();
  const button: HTMLButtonElement = event.target as HTMLButtonElement;
  const target = button.dataset.target;
  const action = button.dataset.action;
  button.disabled = true;

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
    case 'mute':
      targetURL = '/ajax/create_relationship';
      relationshipType = 'mute';
      break;
    case 'unmute':
      targetURL = '/ajax/destroy_relationship';
      relationshipType = 'mute';
      break;
  }
  let success = false;

  post(targetURL, {
    body: {
      screen_name: target,
      type: relationshipType,
    },
    contentType: 'application/json'
  })
    .then(async response => {
      const data = await response.json;

      success = data.success;
      showNotification(data.message, data.success);
    })
    .catch(err => {
      console.log(err);
      showErrorNotification(I18n.translate('frontend.error.message'));
    })
    .finally(() => {
      button.disabled = false;
      if (!success) return;

      switch (action) {
        case 'follow':
          button.dataset.action = 'unfollow';
          button.innerText = I18n.translate('voc.unfollow');
          button.classList.remove('btn-primary');
          button.classList.add('btn-default');
          break;
        case 'unfollow':
          resetFollowButton(button);
          break;
        case 'block':
          button.dataset.action = 'unblock';
          button.querySelector('span').innerText = I18n.translate('voc.unblock');
          if (button.classList.contains('btn')) {
            button.classList.remove('btn-primary');
            button.classList.add('btn-default');
          }
          resetFollowButton(document.querySelector<HTMLButtonElement>('button[data-action="unfollow"]'));
          break;
        case 'unblock':
          button.dataset.action = 'block';
          button.querySelector('span').innerText = I18n.translate('voc.block');
          if (button.classList.contains('btn')) {
            button.classList.remove('btn-default');
            button.classList.add('btn-primary');
          }
          break;
        case 'mute':
          button.dataset.action = 'unmute';
          button.querySelector('span').innerText = I18n.translate('voc.unmute');
          if (button.classList.contains('btn')) {
            button.classList.remove('btn-primary');
            button.classList.add('btn-default');
          }
          break;
        case 'unmute':
          button.dataset.action = 'mute';
          button.querySelector('span').innerText = I18n.translate('voc.mute');
          if (button.classList.contains('btn')) {
            button.classList.remove('btn-default');
            button.classList.add('btn-primary');
          }
          break;
      }
    });
}

function resetFollowButton(button: HTMLButtonElement) {
  button.dataset.action = 'follow';
  button.innerText = I18n.translate('voc.follow');
  button.classList.remove('btn-default');
  button.classList.add('btn-primary');
}
