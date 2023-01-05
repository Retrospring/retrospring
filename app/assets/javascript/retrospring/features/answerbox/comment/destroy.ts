import { post } from '@rails/request.js';
import swal from 'sweetalert';

import I18n from 'retrospring/i18n';
import { showNotification, showErrorNotification } from 'utilities/notifications';

export function commentDestroyHandler(event: Event): void {
  const button = event.target as HTMLButtonElement;
  const id = button.dataset.cId;
  event.preventDefault();
  button.disabled = true;

  swal({
    title: I18n.translate('frontend.destroy_comment.confirm.title'),
    text: I18n.translate('frontend.destroy_comment.confirm.text'),
    type: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#DD6B55',
    confirmButtonText: I18n.translate('voc.delete'),
    cancelButtonText: I18n.translate('voc.cancel'),
    closeOnConfirm: true
  }, (returnValue) => {
    if (returnValue === false) {
      button.disabled = false;
      return;
    }
    
    post('/ajax/destroy_comment', {
      body: {
        comment: id
      },
      contentType: 'application/json'
    })
      .then(async response => {
        const data = await response.json;

        showNotification(data.message);

        document.querySelector(`[data-comment-id="${id}"]`).remove();
      })
      .catch(err => {
        console.log(err);
        showErrorNotification(I18n.translate('frontend.error.message'));
        button.disabled = false;
      });
  });
}