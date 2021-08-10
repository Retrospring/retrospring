import noop from 'retrospring/utilities/noop';

export function createShareEvent(answerbox: HTMLElement): () => void {
  return function (): void {
    navigator.share({
      url: answerbox.querySelector<HTMLAnchorElement>('.answerbox__answer-date > a').href
    })
    .then(noop)
    .catch(noop)
  }
}
