import Rails from '@rails/ujs';
import swal from 'sweetalert';

import I18n from 'retrospring/i18n';
import { showNotification, showErrorNotification } from 'utilities/notifications';

export function destroyCommentHandler(event: Event): void {
  const button = event.target as HTMLButtonElement;
  const id = button.dataset.id;
  event.preventDefault();
  button.disabled = true;

  swal({
    title: I18n.translate('frontend.destroy_comment.confirm.title'),
    text: I18n.translate('frontend.destroy_comment.confirm.text'),
    type: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#DD6B55',
    confirmButtonText: I18n.translate('views.actions.delete'),
    cancelButtonText: I18n.translate('views.actions.cancel'),
    closeOnConfirm: true
  }, (returnValue) => {
    if (returnValue === false) {
      button.disabled = false;
      return;
    }
    
    Rails.ajax({
      url: '/ajax/mod/destroy_comment',
      type: 'POST',
      data: new URLSearchParams({
        comment: id
      }).toString(),
      success: (data) => {
        if (!data.success) return false;

        showNotification(data.message);

        document.querySelector(`[data-comment-id="${id}"]`).remove();
      },
      error: (data, status, xhr) => {
        console.log(data, status, xhr);
        showErrorNotification(I18n.translate('frontend.error.message'));
        button.disabled = false;
      }
    });
  });
}