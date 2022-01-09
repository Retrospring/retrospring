import registerEvents from 'utilities/registerEvents';
import closeAnnouncementHandler from './close';

export default (): void => {
  registerEvents([
    { type: 'click', target: '.announcement button.close', handler: closeAnnouncementHandler, global: true },
  ]);

  document.querySelectorAll('.announcement').forEach(function (el: HTMLDivElement) {
    if (!window.localStorage.getItem(el.dataset.announcementId)) {
      el.classList.remove('d-none');
    }
  });
}
