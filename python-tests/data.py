"""Test data loaded from environment variables with sensible defaults."""

import os
from dataclasses import dataclass


@dataclass(frozen=True)
class FioriTestData:
    """Values used by the Fiori subaccount lifecycle test."""

    subaccount_name: str
    subaccount_description: str
    subaccount_region: str
    display_text_repeat: int
    description_text_repeat: int


def _int_env(name: str, fallback: int) -> int:
    raw = os.getenv(name)
    if not raw:
        return fallback
    try:
        return int(raw)
    except ValueError as exc:
        raise ValueError(f"{name} must be an integer, got: {raw}") from exc


def load_test_data() -> FioriTestData:
    """Build the test data from the environment."""
    return FioriTestData(
        subaccount_name=os.getenv("SUBACCOUNT_NAME", "Tester"),
        subaccount_description=os.getenv("SUBACCOUNT_DESCRIPTION", "Test"),
        subaccount_region=os.getenv("SUBACCOUNT_REGION", "US East (VA) - AWS"),
        display_text_repeat=_int_env("DISPLAY_TEXT_REPEAT", 15),
        description_text_repeat=_int_env("DESC_TEXT_REPEAT", 10),
    )
