export default (): void => {
  if ('share' in navigator) {
    document.body.classList.add('cap-web-share');
  }

  if ('serviceWorker' in navigator) {
    document.body.classList.add('cap-service-worker');
  }

  if ('Notification' in window) {
    document.body.classList.add('cap-notification');
  }
}
