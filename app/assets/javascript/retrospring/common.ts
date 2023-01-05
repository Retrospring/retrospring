import '@hotwired/turbo-rails';
import bootstrap from './initializers/bootstrap';
import stimulus from './initializers/stimulus';

export default function start(): void {
  try {
    bootstrap();
    stimulus();
  } catch (e) {
    // initialization errors
  }
}
