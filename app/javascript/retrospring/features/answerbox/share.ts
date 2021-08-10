export function createShareEvent(answerbox: HTMLElement): () => void {
  return function (): void {
    navigator.share({
      url: answerbox.querySelector<HTMLAnchorElement>('.answerbox__answer-date > a').href
    }).then(() => {
      // do nothing, prevents exce ption from being thrown
    }).catch(() => {
      // do nothing, prevents exception from being thrown
    })
  }
}
