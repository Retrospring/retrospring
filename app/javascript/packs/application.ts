import start from 'retrospring/common';
import initAnswerbox from 'retrospring/features/answerbox/index';
import initInbox from 'retrospring/features/inbox/index';
import initUser from 'retrospring/features/user';
import initLists from 'retrospring/features/lists';

start();
document.addEventListener('turbolinks:load', initAnswerbox);
document.addEventListener('turbolinks:load', initInbox);
document.addEventListener('DOMContentLoaded', initUser);
document.addEventListener('DOMContentLoaded', initLists);