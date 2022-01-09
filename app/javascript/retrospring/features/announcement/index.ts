import registerEvents from 'utilities/registerEvents';
import closeAnnouncementHandler from './close';

export default (): void => {
  registerEvents([
    { type: 'click', target: document.querySelector('.announcement button.close'), handler: closeAnnouncementHandler },
  ]);

  document.querySelectorAll('.announcement').forEach(function (el: HTMLDivElement) {
    if (!window.localStorage.getItem(`announcement${el.dataset.announcementId}`)) {
      el.classList.remove('d-none');
    }
  });
}
