export function commentHotkeyHandler(event: Event): void {
  const button = event.target as HTMLButtonElement;
  const id = button.dataset.aId;
  const answerbox = button.closest('.answerbox');

  if (answerbox !== null) {
    answerbox.querySelector(`#ab-comments-section-${id}`).classList.toggle('d-none');
    answerbox.querySelector<HTMLElement>(`[name="ab-comment-new"][data-a-id="${id}"]`).focus();
  }
}
