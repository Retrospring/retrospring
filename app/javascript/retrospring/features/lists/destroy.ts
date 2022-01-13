import Rails from '@rails/ujs';
import swal from 'sweetalert';
import { showNotification, showErrorNotification } from 'utilities/notifications';
import I18n from 'retrospring/i18n';

export function destroyListHandler(event: Event): void {
  event.preventDefault();
  const button = event.target as HTMLButtonElement;
  const list = button.dataset.list;

  swal({
    title: I18n.translate('frontend.list.confirm.title'),
    text: I18n.translate('frontend.list.confirm.text'),
    type: "warning",
    showCancelButton: true,
    confirmButtonColor: "#DD6B55",
    confirmButtonText: I18n.translate('views.actions.delete'),
    cancelButtonText: I18n.translate('views.actions.cancel'),
    closeOnConfirm: true 
  }, () => {
    Rails.ajax({
      url: '/ajax/destroy_list',
      type: 'POST',
      data: new URLSearchParams({
        list: list
      }).toString(),
      success: (data) => {
        if (data.success) {
          const element = document.querySelector(`li.list-group-item#list-${list}`);

          if (element) {
            element.remove();
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