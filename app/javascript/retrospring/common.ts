import '@hotwired/turbo-rails';
import initializeBootstrap from './initializers/bootstrap';
import initializeServiceWorker from './initializers/serviceWorker';
import initializeStimulus from './initializers/stimulus';

export default function start(): void {
  try {
    initializeBootstrap();
    initializeServiceWorker();
    initializeStimulus();
  } catch (e) {
    // initialization errors
  }
}
