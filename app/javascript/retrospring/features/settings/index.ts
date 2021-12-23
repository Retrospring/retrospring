import {createSubmitEvent} from "retrospring/features/settings/mute";

export default (): void => {
  const submit: HTMLButtonElement = document.getElementById('new-rule-submit') as HTMLButtonElement;
  if (submit.classList.contains('js-initialized')) return;

  const rulesList = document.querySelector<HTMLDivElement>('.js-rules-list');
  const textEntry: HTMLButtonElement = document.getElementById('new-rule-text') as HTMLButtonElement;
  const template: HTMLTemplateElement = document.getElementById('rule-template') as HTMLTemplateElement;

  submit.form.onsubmit = createSubmitEvent(submit, rulesList, textEntry, template)

  submit.classList.add('js-initialized')
}