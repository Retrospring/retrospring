require('../styles/application.scss');

import start from 'retrospring/common';
import initAnnouncements from 'retrospring/features/announcement';
import initAnswerbox from 'retrospring/features/answerbox/index';
import initInbox from 'retrospring/features/inbox/index';
import initUser from 'retrospring/features/user';
import initSettings from 'retrospring/features/settings/index';
import initLists from 'retrospring/features/lists';
import initQuestionbox from 'retrospring/features/questionbox';
import initQuestion from 'retrospring/features/question';
import initModeration from 'retrospring/features/moderation';
import initMemes from 'retrospring/features/memes';
import initLocales from 'retrospring/features/locales';

start();
document.addEventListener('DOMContentLoaded', initAnswerbox);
document.addEventListener('DOMContentLoaded', initInbox);
document.addEventListener('DOMContentLoaded', initUser);
document.addEventListener('turbolinks:load', initSettings);
document.addEventListener('DOMContentLoaded', initLists);
document.addEventListener('DOMContentLoaded', initQuestionbox);
document.addEventListener('DOMContentLoaded', initQuestion);
document.addEventListener('DOMContentLoaded', initModeration);
document.addEventListener('DOMContentLoaded', initMemes);
document.addEventListener('turbolinks:load', initAnnouncements);
document.addEventListener('turbolinks:load', initLocales);