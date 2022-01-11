import Coloris from "@melloware/coloris";

let previewStyle = null;
let previewTimeout = null;

const previewTheme = (): void => {
  const payload = {};

  Array.from(document.querySelectorAll('#update_theme .color')).forEach((color: HTMLInputElement) => {
    const name = color.name.substring(6, color.name.length - 1);
    payload[name] = parseInt(color.value.substr(1, 6), 16);
  });

  generateTheme(payload);
}

const generateTheme = (payload: Record<string, string>): void => {
  const themeAttributeMap = {
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
    'raised_accent': 'raised-accent',
    'background_color': 'background',
    'body_text': 'body-text',
    'input_color': 'input-bg',
    'input_text': 'input-text',
    'muted_text': 'muted-text'
  };

  let body = ":root {\n";

  (Object.keys(payload)).forEach((payloadKey) => {
    if (themeAttributeMap[payloadKey]) {
      if (themeAttributeMap[payloadKey].includes('text')) {
        const hex = getHexColorFromThemeValue(payload[payloadKey]);
        body += `--${themeAttributeMap[payloadKey]}: ${getDecimalTripletsFromHex(hex)};\n`;
      }
      else {
        body += `--${themeAttributeMap[payloadKey]}: #${getHexColorFromThemeValue(payload[payloadKey])};\n`;
      }
    }
  });

  body += "}";

  previewStyle.innerHTML = body;
}

const getHexColorFromThemeValue = (themeValue: string): string => {
  return ('000000' + parseInt(themeValue).toString(16)).substr(-6, 6);
}

const getDecimalTripletsFromHex = (hex: string): string => {
  return hex.match(/.{1,2}/g).map((value) => parseInt(value, 16)).join(', ');
}

export function themeDocumentHandler(): void {
  if (!document.querySelector('#update_theme')) return;
  if (document.querySelector('#clr-picker')) return;

  previewStyle = document.createElement('style');
  previewStyle.setAttribute('data-preview-style', '');
  document.body.appendChild(previewStyle);

  Coloris.init();

  Array.from(document.querySelectorAll('#update_theme .color')).forEach((color: HTMLInputElement) => {
    // If there already is a hex-color in the input, skip
    if (color.value.startsWith('#')) return;

    let colorValue;

    // match for value="[digits]" to ALWAYS get a color value
    // TODO: Fix this later with rethinking the entire lifecycle, or dropping Turbolinks
    colorValue = color.outerHTML.match(/value="(\d+)"/)[1];

    // matching failed, or no result was found, we just fallback to the input value
    if (colorValue === null) {
      colorValue = color.value;
    }

    color.value = `#${getHexColorFromThemeValue(colorValue)}`;

    Coloris({
      el: '.color',
      wrap: false,
      formatToggle: false,
      alpha: false
    });

    color.addEventListener('input', () => {
      clearTimeout(previewTimeout);
      previewTimeout = setTimeout(previewTheme, 1000);
    });
  });
}

export function themeSubmitHandler(): void {
  Array.from(document.querySelectorAll('#update_theme .color')).forEach((color: HTMLInputElement) => {
    color.value = String(parseInt(color.value.substr(1, 6), 16));
  });
}