export function authorSearchHandler(event: Event): void {
  event.preventDefault();

  const author = document.querySelector<HTMLInputElement>('#author')?.value;
  window.location.href = `/inbox/${author}`;
}