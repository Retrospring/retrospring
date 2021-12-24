import start from 'retrospring/common';
import initAnswerbox from 'retrospring/features/answerbox/index';
import initInbox from 'retrospring/features/inbox/index';

start();
document.addEventListener('turbolinks:load', initAnswerbox);
document.addEventListener('turbolinks:load', initInbox);