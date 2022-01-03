import start from 'retrospring/common';
import initAnswerbox from 'retrospring/features/answerbox/index';
import initInbox from 'retrospring/features/inbox/index';
import initUser from 'retrospring/features/user';
import initSettings from 'retrospring/features/settings/index';
import initLists from 'retrospring/features/lists';
import initQuestionbox from 'retrospring/features/questionbox';

start();
document.addEventListener('turbolinks:load', initAnswerbox);
document.addEventListener('DOMContentLoaded', initInbox);
document.addEventListener('DOMContentLoaded', initUser);
document.addEventListener('turbolinks:load', initSettings);
document.addEventListener('DOMContentLoaded', initLists);
document.addEventListener('DOMContentLoaded', initQuestionbox);