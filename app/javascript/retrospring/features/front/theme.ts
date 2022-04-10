export function themeButtonHandler(event: Event): void {
  const button = event.currentTarget as HTMLButtonElement;
  event.preventDefault();
  
  const theme = button.dataset.theme;

  document.body.setAttribute('class', 'not-logged-in');

  if (theme === 'reset') return;

  if (!document.body.classList.contains(theme)) {
    document.body.classList.add(theme);
  }
}