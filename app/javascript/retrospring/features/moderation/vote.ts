import Rails from '@rails/ujs';

import I18n from 'retrospring/i18n';
import { showNotification, showErrorNotification } from 'utilities/notifications';

export function voteReportHandler(event: Event): void {
  const button = event.target as HTMLButtonElement;
  const id = button.dataset.id;
  const action = button.dataset.action;
  const upvote = button.dataset.voteType === 'upvote';
  button.disabled = true;

  let success = false;
  let targetUrl;

  if (action === 'vote') {
    targetUrl = '/ajax/mod/create_vote';
  }
  else if (action === 'unvote') {
    targetUrl = '/ajax/mod/destroy_vote';
  }

  Rails.ajax({
    url: targetUrl,
    type: 'POST',
    data: new URLSearchParams({
      id: id,
      upvote: String(upvote)
    }).toString(),
    success: (data) => {
      success = data.success;
      if (success) {
        document.querySelector(`span#mod-count-${id}`).innerHTML = data.count;
      }

      showNotification(data.message);
    },
    error: (data, status, xhr) => {
      console.log(data, status, xhr);
      showErrorNotification(I18n.translate('frontend.error.message'));
    },
    complete: () => {
      if (success) {
        const inverseVoteButton = document.querySelector<HTMLButtonElement>(`[name=mod-vote][data-id="${id}"][data-vote-type="${ upvote ? 'downvote' : 'upvote' }"]`);
        const inverseUnvoteButton = document.querySelector<HTMLButtonElement>(`[name=mod-vote][data-id="${id}"][data-vote-type="${ upvote ? 'downvote' : 'upvote' }"]`);
        
        switch (action) {
          case 'vote':
            button.disabled = true;
            button.dataset.action = 'unvote';
  
            inverseVoteButton.disabled = false;
            inverseVoteButton.dataset.action = 'unvote';
            break;
          case 'unvote':
            button.disabled = false;
            button.dataset.action = 'vote';
  
            inverseUnvoteButton.disabled = false;
            inverseUnvoteButton.dataset.action = 'vote';
            break;
        }
      }
    }
  });
}