import translations from "../translations";
import { Translations } from "../types/Translations";

// we currently have only polish language, so we set it as default
// in the future we can add a language switcher or use i18n library
let currentLanguage = "pl";

export const setLanguage = (language: string) => {
  currentLanguage = language;
};

export const useTranslation = (): Translations => {
  return translations[currentLanguage];
};
