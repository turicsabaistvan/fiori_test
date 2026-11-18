/**
 * Environment helpers for the E2E suite.
 *
 * Credentials must be provided via FIORI_USERNAME / FIORI_PASSWORD.
 * Test data can be overridden through environment variables.
 */

export function requireEnv(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

export function optionalEnv(name: string, fallback: string): string {
  const value = process.env[name];
  return value && value.length > 0 ? value : fallback;
}

export function optionalIntEnv(name: string, fallback: number): number {
  const raw = process.env[name];
  if (!raw) return fallback;

  const parsed = Number.parseInt(raw, 10);
  if (Number.isNaN(parsed)) {
    throw new Error(
      `Environment variable ${name} must be an integer, got: ${raw}`
    );
  }
  return parsed;
}

export const testData = {
  subaccountName: optionalEnv('SUBACCOUNT_NAME', 'Tester'),
  subaccountDescription: optionalEnv('SUBACCOUNT_DESCRIPTION', 'Test'),
  subaccountRegion: optionalEnv('SUBACCOUNT_REGION', 'US East (VA) - AWS'),
  displayTextRepeat: optionalIntEnv('DISPLAY_TEXT_REPEAT', 15),
  descriptionTextRepeat: optionalIntEnv('DESC_TEXT_REPEAT', 10),
} as const;
