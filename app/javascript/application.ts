import start from 'retrospring/common';
import initSettings from 'retrospring/features/settings/index';
import initMemes from 'retrospring/features/memes';
import initFront from 'retrospring/features/front';

start();
document.addEventListener('turbo:load', initSettings);
document.addEventListener('DOMContentLoaded', initMemes);
document.addEventListener('turbo:load', initFront);


