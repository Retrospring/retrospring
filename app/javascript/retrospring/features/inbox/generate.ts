import Rails from '@rails/ujs';

import { updateDeleteButton } from './delete';

export function generateQuestionHandler(): void {
  Rails.ajax({
    url: '/ajax/generate_question',
    type: 'POST',
    dataType: 'json',
    success: (data) => {
      if (!data.success) return false;

      document.querySelector('#entries').insertAdjacentHTML('afterbegin', data.render);
      updateDeleteButton();
    },
    error: (data, status, xhr) => {
      console.log(data, status, xhr);
    }
  });
}
