import '@hotwired/turbo-rails';
import initializeBootstrap from './initializers/bootstrap';
import initializeHotkey from './initializers/hotkey';
import initializeServiceWorker from './initializers/serviceWorker';
import initializeStimulus from './initializers/stimulus';

export default function start(): void {
  try {
    initializeBootstrap();
    initializeHotkey();
    initializeServiceWorker();
    initializeStimulus();
  } catch (e) {
    // initialization errors
  }
}
