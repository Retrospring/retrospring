import Rails from '@rails/ujs';
import I18n from '../../../legacy/i18n';

export function createListHandler(event: Event): void {
  const button = event.target as HTMLButtonElement;
  const input = document.querySelector<HTMLInputElement>('input#new-list-name');

  Rails.ajax({
    url: '/ajax/create_list',
    type: 'POST',
    data: new URLSearchParams({
      name: input.value,
      user: button.dataset.user
    }).toString(),
    success: (data) => {
      if (data.success) {
        document.querySelector('#lists-list ul.list-group').insertAdjacentHTML('beforeend', data.render);
      }
      
      window['showNotification'](data.message, data.success);
    },
    error: (data, status, xhr) => {
      console.log(data, status, xhr);
      window['showNotification'](I18n.translate('frontend.error.message'), false);
    }
  });
}

export function createListInputHandler(event: KeyboardEvent): void {
  if (event.which === 13) {
    event.preventDefault();
    document.querySelector<HTMLButtonElement>('button#create-list').click();
  }
}