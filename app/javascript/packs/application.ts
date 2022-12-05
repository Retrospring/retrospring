require('../styles/application.scss');

import { Application } from '@hotwired/stimulus';
import { definitionsFromContext } from '@hotwired/stimulus-webpack-helpers';

import start from 'retrospring/common';
import initAnswerbox from 'retrospring/features/answerbox/index';
import initInbox from 'retrospring/features/inbox/index';
import initUser from 'retrospring/features/user';
import initSettings from 'retrospring/features/settings/index';
import initQuestionbox from 'retrospring/features/questionbox';
import initQuestion from 'retrospring/features/question';
import initModeration from 'retrospring/features/moderation';
import initMemes from 'retrospring/features/memes';
import initLocales from 'retrospring/features/locales';
import initFront from 'retrospring/features/front';

start();
document.addEventListener('DOMContentLoaded', initAnswerbox);
document.addEventListener('DOMContentLoaded', initInbox);
document.addEventListener('DOMContentLoaded', initUser);
document.addEventListener('turbo:load', initSettings);
document.addEventListener('turbo:load', initQuestionbox);
document.addEventListener('DOMContentLoaded', initQuestion);
document.addEventListener('DOMContentLoaded', initModeration);
document.addEventListener('DOMContentLoaded', initMemes);
document.addEventListener('turbo:load', initLocales);
document.addEventListener('turbo:load', initFront);

window['Stimulus'] = Application.start();
const context = require.context('../retrospring/controllers', true, /\.ts$/);
window['Stimulus'].load(definitionsFromContext(context));
