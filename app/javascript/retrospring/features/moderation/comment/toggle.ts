export function entryCommentToggle(event: Event): void {
  const button = event.target as HTMLButtonElement;
  const id = button.dataset.id;

  document.querySelector(`#mod-comments-section-${id}`).classList.toggle('d-none');
}