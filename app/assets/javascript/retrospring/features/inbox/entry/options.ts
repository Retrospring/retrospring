export default function optionsEntryHandler(event: Event): void {
  const button = event.target as HTMLElement;
  const inboxId = button.dataset.ibId;

  const options = document.querySelector(`#ib-options-${inboxId}`);
  options.classList.toggle('d-none');
}