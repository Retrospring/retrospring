import noop from 'utilities/noop';

export function shareEventHandler(event: Event): void {
  event.preventDefault();
  const answerbox = (event.target as HTMLElement).closest('.answerbox');

  navigator.share({
    url: answerbox.querySelector<HTMLAnchorElement>('.answerbox__answer-date > a, a.answerbox__permalink').href
  })
    .then(noop)
    .catch(noop)
}
