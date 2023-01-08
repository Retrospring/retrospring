export default function optionsEntryHandler(event: Event): void {
  const button = event.target as HTMLElement;
  const inboxId = button.dataset.ibId;

  const options = document.querySelector(`#ib-options-${inboxId}`);
  options.classList.toggle('d-none');

  const buttonIcon = button.getElementsByTagName('i')[0];
  if (buttonIcon.classList.contains('fa-chevron-down')) {
    buttonIcon.classList.remove('fa-chevron-down');
    buttonIcon.classList.add('fa-chevron-up');
  } else {
    buttonIcon.classList.remove('fa-chevron-up');
    buttonIcon.classList.add('fa-chevron-down');
  }
}
