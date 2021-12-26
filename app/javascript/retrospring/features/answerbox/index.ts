import { on } from 'retrospring/utilities/on';
import { shareEventHandler } from './share';

export default (): void => {
  if ('share' in navigator) {
    document.body.classList.add('cap-web-share');

    on('click', '[name=ab-share]', shareEventHandler);
  }
}
