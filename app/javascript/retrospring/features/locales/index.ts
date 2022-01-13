import registerEvents from 'utilities/registerEvents';

function localeSwitchHandler(event: Event): void {
  event.preventDefault();
  document.querySelector('#locales-panel').classList.toggle('d-block');
}

export default (): void => {
  registerEvents([
    { type: 'click', target: document.querySelector('#locale-switch'), handler: localeSwitchHandler }
  ]);
}