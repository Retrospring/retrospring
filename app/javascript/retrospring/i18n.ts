
import Cookies from 'js-cookie'
import { I18n } from "i18n-js"
import translations from "./i18n.json";

const i18n = new I18n();
i18n.store(translations);
i18n.defaultLocale = "en";
i18n.enableFallback = true;
i18n.locale = Cookies.get('hl') || 'en';

export default i18n;
