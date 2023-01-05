import { post } from '@rails/request.js';
import { showNotification, showErrorNotification } from 'utilities/notifications';
import I18n from 'retrospring/i18n';

export function listMembershipHandler(event: Event): void {
  const checkbox = event.target as HTMLInputElement;
  const list = checkbox.dataset.list;
  const memberCountElement: HTMLElement = document.querySelector(`span#${list}-members`);
  let memberCount = Number(memberCountElement.dataset.count);

  checkbox.setAttribute('disabled', 'disabled');

  memberCount += checkbox.checked ? 1 : -1;

  post('/ajax/list_membership', {
    body: {
      list: list,
      user: checkbox.dataset.user,
      add: String(checkbox.checked)
    },
    contentType: 'application/json'
  })
    .then(async response => {
      const data = await response.json;

      if (data.success) {
        checkbox.checked = data.checked;
        memberCountElement.innerHTML = I18n.t('frontend.list.item.members', { count: memberCount });
        memberCountElement.dataset.count = memberCount.toString();
      }

      showNotification(data.message, data.success);
    })
    .catch(err => {
      console.log(err);
      showErrorNotification(I18n.translate('frontend.error.message'));
    })
    .finally(() => {
      checkbox.removeAttribute('disabled');
    });
}