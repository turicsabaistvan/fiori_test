/**
 * Selectors for the SAP IDP login page.
 */
export const LoginSelectors = {
  usernameInput: 'input[placeholder="E-mail vagy felhasználónév"]',
  passwordInput: 'input[placeholder="Jelszó"]',
  submitButton: '#logOnFormSubmit',
  errorMessage: 'text="Nem tudtuk hitelesíteni Önt."',
  cookieBannerButton:
    'div#truste-consent-buttons button#truste-consent-required',
} as const;