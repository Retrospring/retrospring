import { post } from '@rails/request.js';
import { showErrorNotification, showNotification } from 'utilities/notifications';
import swal from 'sweetalert';

import I18n from 'retrospring/i18n';

export function answerboxDestroyHandler(event: Event): void {
  event.preventDefault();
  const button = event.target as HTMLButtonElement;
  const answerId = button.dataset.aId;

  swal({
    title: I18n.translate('frontend.destroy_own.confirm.title'),
    text: I18n.translate('frontend.destroy_own.confirm.text'),
    type: "warning",
    showCancelButton: true,
    confirmButtonColor: "#DD6B55",
    confirmButtonText: I18n.translate('voc.y'),
    cancelButtonText: I18n.translate('voc.n'),
    closeOnConfirm: true
  }, (returnValue) => {
    if (returnValue === false) {
      button.disabled = false;
      return;
    }

    post('/ajax/destroy_answer', {
      body: {
        answer: answerId
      },
      contentType: 'application/json'
    })
      .then(async response => {
        const data = await response.json;

        if (data.success) {
          document.querySelector(`.answerbox[data-id="${answerId}"]`).remove();
        }
        
        showNotification(data.message, data.success);
      })
      .catch(err => {
        console.log(err);
        showErrorNotification(I18n.translate('frontend.error.message'));
      });
  });
}