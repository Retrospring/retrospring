import Rails from '@rails/ujs';
import swal from 'sweetalert';

import I18n from '../../i18n';

export function deleteAllQuestionsHandler(event: Event): void {
  const button = event.currentTarget as Element;
  const count = button.getAttribute('data-ib-count');

  swal({
    title: I18n.t('frontend.inbox.confirm_all.title', { count: count }),
    text: I18n.t('frontend.inbox.confirm_all.text'),
    icon: 'warning',
    dangerMode: true,
    buttons: [
      I18n.t('views.actions.cancel'),
      I18n.t('views.actions.delete')
    ]
  })
  .then((returnValue) => {
    if (returnValue === null) return false;
    
    Rails.ajax({
      url: '/ajax/delete_all_inbox',
      type: 'POST',
      dataType: 'json',
      success: (data) => {
        if (!data.success) return false;
  
        document.querySelector('#entries').innerHTML = 'Nothing to see here!';
      },
      error: (data, status, xhr) => {
        console.log(data, status, xhr);
      }
    });
  });
}
