import { post } from '@rails/request.js';
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
    confirmButtonText: I18n.translate('voc.delete'),
    cancelButtonText: I18n.translate('voc.cancel'),
    closeOnConfirm: true 
  }, () => {
    post('/ajax/destroy_list', {
      body: {
        list: list
      },
      contentType: 'application/json'
    })
      .then(async response => {
        const data = await response.json;

        if (data.success) {
          const element = document.querySelector(`li.list-group-item#list-${list}`);

          if (element) {
            element.remove();
          }
        }
        
        showNotification(data.message, data.success);
      })
      .catch(err => {
        console.log(err);
        showErrorNotification(I18n.translate('frontend.error.message'));
      });
  });
}