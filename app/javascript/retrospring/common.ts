import '@hotwired/turbo-rails';
import initializeBootstrap from './initializers/bootstrap';
import initializeStimulus from './initializers/stimulus';

export default function start(): void {
  try {
    initializeBootstrap();
    initializeStimulus();
  } catch (e) {
    // initialization errors
  }
}
