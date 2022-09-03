import { post } from '@rails/request.js';
import { showNotification, showErrorNotification } from 'utilities/notifications';
import I18n from 'retrospring/i18n';

export function createListHandler(event: Event): void {
  const button = event.target as HTMLButtonElement;
  const input = document.querySelector<HTMLInputElement>('input#new-list-name');

  post('/ajax/create_list', {
    body: {
      name: input.value,
      user: button.dataset.user
    },
    contentType: 'application/json'
  })
    .then(async response => {
      const data = await response.json;

      if (data.success) {
        document.querySelector('#lists-list ul.list-group').insertAdjacentHTML('beforeend', data.render);
      }
      
      showNotification(data.message, data.success);
    })
    .catch(err => {
      console.log(err);
      showErrorNotification(I18n.translate('frontend.error.message'));
    });
}

export function createListInputHandler(event: KeyboardEvent): void {
  // Return key
  if (event.which === 13) {
    event.preventDefault();
    document.querySelector<HTMLButtonElement>('button#create-list').click();
  }
}