import Rails from '@rails/ujs';
import { showNotification, showErrorNotification } from 'utilities/notifications';
import I18n from 'retrospring/i18n';

export function listMembershipHandler(event: Event): void {
  const checkbox = event.target as HTMLInputElement;
  const list = checkbox.dataset.list;
  let memberCount = Number(document.querySelector(`span#${list}-members`).innerHTML);

  checkbox.setAttribute('disabled', 'disabled');

  memberCount += checkbox.checked ? 1 : -1;

  Rails.ajax({
    url: '/ajax/list_membership',
    type: 'POST',
    data: new URLSearchParams({
      list: list,
      user: checkbox.dataset.user,
      add: String(checkbox.checked)
    }).toString(),
    success: (data) => {
      if (data.success) {
        checkbox.checked = data.checked;
        document.querySelector(`span#${list}-members`).innerHTML = memberCount.toString();
      }

      showNotification(data.message, data.success);
    },
    error: (data, status, xhr) => {
      console.log(data, status, xhr);
      showErrorNotification(I18n.translate('frontend.error.message'));
    },
    complete: () => {
      checkbox.removeAttribute('disabled');
    }
  });
}