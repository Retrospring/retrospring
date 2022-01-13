import Rails from '@rails/ujs';

import I18n from 'retrospring/i18n';
import { showNotification, showErrorNotification } from 'utilities/notifications';

export function commentCreateHandler(event: KeyboardEvent): boolean {
  const input = event.target as HTMLInputElement;
  const id = input.dataset.aId;
  const counter = document.querySelector(`#ab-comment-charcount-${id}`);
  const group = document.querySelector(`[name=ab-comment-new-group][data-a-id="${id}"]`);

  if (event.which === 13) {
    event.preventDefault();

    if (input.value.length > 160) {
      group.classList.add('has-error');
      return true;
    }

    input.disabled = true;

    Rails.ajax({
      url: '/ajax/create_comment',
      type: 'POST',
      data: new URLSearchParams({
        answer: id,
        comment: input.value
      }).toString(),
      success: (data) => {
        if (data.success) {
          document.querySelector(`#ab-comments-${id}`).innerHTML = data.render;
          document.querySelector(`#ab-comment-count-${id}`).innerHTML = data.count;
          input.value = '';
          counter.innerHTML = String(160);

          const sub = document.querySelector<HTMLElement>(`[data-action=ab-submarine][data-a-id="${id}"]`);
          sub.dataset.torpedo = "no"
          sub.children[0].nextSibling.textContent = ' ' + I18n.translate('views.actions.unsubscribe');
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