import cheet from 'cheet.js';

export default (): void => {
  cheet('up up down down left right left right b a', () => {
    document.body.classList.add('fa-spin');
  });
}
