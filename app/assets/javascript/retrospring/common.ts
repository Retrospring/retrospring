import '@hotwired/turbo-rails';
import bootstrap from './initializers/bootstrap';

export default function start(): void {
  try {
    bootstrap();
  } catch (e) {
    // initialization errors
  }
}
