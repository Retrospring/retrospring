import Rails from '@rails/ujs';
import { showErrorNotification, showNotification } from 'utilities/notifications';
import swal from 'sweetalert';

import I18n from 'retrospring/i18n';

export function questionboxDestroyHandler(event: Event): void {
  event.preventDefault();
  const button = event.target as HTMLButtonElement;
  const questionId = button.dataset.qId;

  swal({
    title: I18n.translate('frontend.destroy_own.confirm.title'),
    text: I18n.translate('frontend.destroy_own.confirm.text'),
    type: "warning",
    showCancelButton: true,
    confirmButtonColor: "#DD6B55",
    confirmButtonText: I18n.translate('views.actions.y'),
    cancelButtonText: I18n.translate('views.actions.n'),
    closeOnConfirm: true
  }, (returnValue) => {
    if (returnValue === false) {
      button.disabled = false;
      return;
    }
    
    Rails.ajax({
      url: '/ajax/destroy_question',
      type: 'POST',
      data: new URLSearchParams({
        question: questionId
      }).toString(),
      success: (data) => {
        if (data.success) {
          if (button.dataset.redirect !== undefined) {
            window.location.pathname = button.dataset.redirect;
          }
          else {
            Array.from(document.querySelectorAll(`div.answerbox[data-q-id="${questionId}"], div.questionbox[data-id="${questionId}"]`)).forEach((element: HTMLElement) => {
              element.remove();
            });
          }
        }
        
        showNotification(data.message, data.success);
      },
      error: (data, status, xhr) => {
        console.log(data, status, xhr);
        showErrorNotification(I18n.translate('frontend.error.message'));
      }
    });
  });
}