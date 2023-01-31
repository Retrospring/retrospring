export const THEME_MAPPING = {
  'primary_color': 'primary',
  'primary_text': 'primary-text',
  'danger_color': 'danger',
  'danger_text': 'danger-text',
  'warning_color': 'warning',
  'warning_text': 'warning-text',
  'info_color': 'info',
  'info_text': 'info-text',
  'success_color': 'success',
  'success_text': 'success-text',
  'dark_color': 'dark',
  'dark_text': 'dark-text',
  'light_color': 'light',
  'light_text': 'light-text',
  'raised_background': 'raised-bg',
  'raised_text': 'raised-text',
  'raised_accent': 'raised-accent',
  'raised_accent_text': 'raised-accent-text',
  'background_color': 'background',
  'body_text': 'body-text',
  'input_color': 'input-bg',
  'input_text': 'input-text',
  'input_placeholder': 'input-placeholder',
  'muted_text': 'muted-text'
};

export const getHexColorFromThemeValue = (themeValue: string): string => {
  return ('000000' + parseInt(themeValue).toString(16)).substr(-6, 6);
}

export const getDecimalTripletsFromHex = (hex: string): string => {
  return hex.match(/.{1,2}/g).map((value) => parseInt(value, 16)).join(', ');
}

export const getIntegerFromHexColor = (hex: string): number => {
  return parseInt(hex.substr(1, 6), 16);
}

export const getColorForKey = (key: string, color: string): string => {
  const hex = getHexColorFromThemeValue(color);

  if (key.includes('text') || key.includes('placeholder') || key.includes('rgb')) {
    return getDecimalTripletsFromHex(hex);
  } else {
    return `#${hex}`;
  }
};
