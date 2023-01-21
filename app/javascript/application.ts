import start from 'retrospring/common';
import initAnswerbox from 'retrospring/features/answerbox/index';
import initInbox from 'retrospring/features/inbox/index';
import initUser from 'retrospring/features/user';
import initSettings from 'retrospring/features/settings/index';
import initLists from 'retrospring/features/lists';
import initQuestionbox from 'retrospring/features/questionbox';
import initQuestion from 'retrospring/features/question';
import initModeration from 'retrospring/features/moderation';
import initMemes from 'retrospring/features/memes';
import initFront from 'retrospring/features/front';
import initWebpush from 'retrospring/features/webpush';
import initWebpushSettingsButtons from 'retrospring/features/webpush/settingsButtons';

start();
document.addEventListener('DOMContentLoaded', initAnswerbox);
document.addEventListener('DOMContentLoaded', initInbox);
document.addEventListener('DOMContentLoaded', initUser);
document.addEventListener('turbo:load', initSettings);
document.addEventListener('DOMContentLoaded', initLists);
document.addEventListener('turbo:load', initQuestionbox);
document.addEventListener('DOMContentLoaded', initQuestion);
document.addEventListener('DOMContentLoaded', initModeration);
document.addEventListener('DOMContentLoaded', initMemes);
document.addEventListener('turbo:load', initFront);
document.addEventListener('DOMContentLoaded', initWebpush);
document.addEventListener('turbo:load', initWebpushSettingsButtons);


