import Rails from '@rails/ujs';

import I18n from 'retrospring/i18n';
import { showNotification, showErrorNotification } from 'utilities/notifications';

export function commentCreateHandler(event: KeyboardEvent): boolean {
  const input = event.target as HTMLInputElement;
  const id = input.dataset.id;
  const counter = document.querySelector(`#mod-comment-charcount-${id}`);
  const group = document.querySelector(`[name=mod-comment-new-group][data-id="${id}"]`);

  if (event.which === 13) {
    event.preventDefault();

    if (input.value.length > 160) {
      group.classList.add('has-error');
      return true;
    }

    input.disabled = true;

    Rails.ajax({
      url: '/ajax/mod/create_comment',
      type: 'POST',
      data: new URLSearchParams({
        id: id,
        comment: input.value
      }).toString(),
      success: (data) => {
        if (data.success) {
          document.querySelector(`#mod-comments-${id}`).insertAdjacentHTML('beforeend', data.render);
          document.querySelector(`#mod-comment-count-${id}`).innerHTML = data.count;
          input.value = '';
          counter.innerHTML = String(160);
        }

        showNotification(data.message, data.success);
      },
      error: (data, status, xhr) => {
        console.log(data, status, xhr);
        showErrorNotification(I18n.translate('frontend.error.message'));
      },
      complete: () => {
        input.disabled = false;
      }
    });
  }
}