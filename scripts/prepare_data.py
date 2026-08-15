#!/usr/bin/env python3
"""
prepare_data.py — Download and prepare Quran & Hadith JSON data for bundling
in the Flutter app.

Outputs (into assets/data/):
  quran_uthmani.json           – Uthmanic Arabic text keyed by surah number
  quran_en_translation.json    – English translation keyed by surah number
  surah_info.json              – Array of 114 surah metadata objects
  quran_word_by_word.json      – Nested {surah: {ayah: {…AyahWordAnalysis}}}

Usage:
  python3 scripts/prepare_data.py
  python3 scripts/prepare_data.py --output-dir assets/data
  python3 scripts/prepare_data.py --skip-existing          # skip already-downloaded files
  python3 scripts/prepare_data.py --uthmani-only           # only step 1

Data sources (tried in order):
  Primary:   api.alquran.cloud API (richer data with juz, page, sajda per ayah)
  Fallback:  islamic-network/quran-json GitHub repo (flat {surah: [ayahs]} format)
"""

from __future__ import annotations

import argparse
import json
import sys
import time
import urllib.request
import urllib.error
from pathlib import Path
from typing import Any

# ── Configuration ─────────────────────────────────────────────────────

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent

DEFAULT_OUTPUT_DIR = PROJECT_ROOT / "assets" / "data"

# Primary sources: alquran.cloud API
ALQURAN_CLOUD = {
    "uthmani": "https://api.alquran.cloud/v1/quran/quran-uthmani",
    "en_translation": "https://api.alquran.cloud/v1/quran/en.sahih",
    "surah_info": "https://api.alquran.cloud/v1/surah",
}

# Fallback sources: islamic-network/quran-json GitHub (may 404 if repo removed)
GITHUB_FALLBACKS = {
    "uthmani": [
        "https://raw.githubusercontent.com/islamic-network/quran-json/refs/heads/master/uthmani.json",
        "https://raw.githubusercontent.com/islamic-network/quran-json/master/uthmani.json",
    ],
    "en_translation": [
        "https://raw.githubusercontent.com/islamic-network/quran-json/refs/heads/master/en.json",
        "https://raw.githubusercontent.com/islamic-network/quran-json/master/en.json",
    ],
}

# Word-by-word data source
WORD_BY_WORD_URL = (
    "https://raw.githubusercontent.com/IdrisIbnMustafa/"
    "quran-word-by-word/main/json/word_by_word_uthmani.json"
)

# Juz lookup: (surah, first_ayah_of_juz) — 30 entries.
JUZ_BREAKDOWN = [
    (1, 1), (2, 142), (2, 253), (3, 93), (4, 24), (4, 148),
    (5, 82), (6, 151), (7, 88), (8, 41), (9, 93), (11, 6),
    (12, 53), (15, 1), (17, 1), (18, 75), (21, 1), (22, 39),
    (23, 1), (25, 21), (27, 56), (29, 46), (33, 31), (36, 23),
    (39, 32), (41, 47), (46, 1), (51, 31), (58, 1), (67, 1),
    (78, 1),
]

REQUEST_TIMEOUT = 60  # seconds
RETRY_ATTEMPTS = 3
RETRY_BACKOFF = 2  # seconds base, doubled each retry

# ── Helpers ───────────────────────────────────────────────────────────


def log(msg: str) -> None:
    """Print a timestamped log line."""
    ts = time.strftime("%H:%M:%S")
    print(f"[{ts}] {msg}", flush=True)


def download_json(url: str, retries: int = RETRY_ATTEMPTS) -> Any:
    """Fetch *url*, parse as JSON, with retry logic."""
    for attempt in range(1, retries + 1):
        try:
            log(f"  Fetching {url}  (attempt {attempt}/{retries}) …")
            req = urllib.request.Request(
                url,
                headers={"User-Agent": "prepare_data.py/1.0"},
            )
            with urllib.request.urlopen(req, timeout=REQUEST_TIMEOUT) as resp:
                raw = resp.read()
                data = json.loads(raw)
            log(f"  ✓ Downloaded ({len(raw):,} bytes)")
            return data
        except urllib.error.HTTPError as exc:
            log(f"  ✗ HTTP {exc.code} – {exc.reason}")
        except urllib.error.URLError as exc:
            log(f"  ✗ URL error – {exc.reason}")
        except json.JSONDecodeError as exc:
            log(f"  ✗ JSON decode error – {exc}")
        except Exception as exc:  # noqa: BLE001
            log(f"  ✗ {type(exc).__name__}: {exc}")

        if attempt < retries:
            wait = RETRY_BACKOFF * (2 ** (attempt - 1))
            log(f"  Retrying in {wait}s …")
            time.sleep(wait)

    raise RuntimeError(f"Failed to download {url} after {retries} attempts")


def download_json_with_fallbacks(urls: list[str]) -> Any:
    """Try a list of URLs in order; return data from the first success."""
    last_err: Exception | None = None
    for url in urls:
        try:
            return download_json(url)
        except RuntimeError as exc:
            last_err = exc
    raise RuntimeError(
        f"All URLs failed. Last error: {last_err}"
    ) if last_err else RuntimeError("No URLs provided")


def save_json(path: Path, data: Any, *, indent: int = 2) -> None:
    """Write *data* as formatted JSON to *path*, ensuring the parent dir exists."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(data, fh, ensure_ascii=False, indent=indent)
    size_kb = path.stat().st_size / 1024
    log(f"  ✓ Saved → {path.relative_to(PROJECT_ROOT)}  ({size_kb:.1f} KB)")


def compute_juz_for_ayah(surah: int, ayah_in_surah: int) -> int:
    """Return the juz number (1–30) that contains the given ayah."""
    for juz_idx in range(len(JUZ_BREAKDOWN) - 1, -1, -1):
        juz_start = JUZ_BREAKDOWN[juz_idx]
        if (surah, ayah_in_surah) >= juz_start:
            return juz_idx + 1
    return 1


def _clean_arabic_text(text: str) -> str:
    """Strip BOM, zero-width characters, and leading/trailing whitespace."""
    # Remove BOM
    text = text.lstrip("\ufeff")
    # Remove common zero-width characters
    for ch in ["\u200c", "\u200d", "\u200e", "\u200f", "\ufeff"]:
        text = text.replace(ch, "")
    return text.strip()


def extract_surah_texts_from_alquran(
    api_data: dict[str, Any],
) -> dict[str, list[str]]:
    """Transform alquran.cloud response into flat {"surah": [ayah_strings]}.

    alquran.cloud format:
      {"data": {"surahs": [{"number": 1, "ayahs": [{"text": "..."}, ...]}, ...]}}

    Output format:
      {"1": ["ayah1_text", "ayah2_text", ...], "2": [...], ...}
    """
    surahs = api_data.get("data", {}).get("surahs", [])
    result: dict[str, list[str]] = {}
    for surah in surahs:
        surah_num = str(surah["number"])
        result[surah_num] = [
            _clean_arabic_text(ayah["text"]) for ayah in surah["ayahs"]
        ]
    return result


def extract_surah_texts_from_github(
    github_data: dict[str, Any],
) -> dict[str, list[str]]:
    """Pass through the GitHub format, cleaning each ayah text."""
    result: dict[str, list[str]] = {}
    for surah_key, ayahs in github_data.items():
        result[surah_key] = [_clean_arabic_text(a) for a in ayahs]
    return result


# ── Step 1: Quran Uthmanic Text ───────────────────────────────────────


def download_uthmani(output_dir: Path, *, skip_existing: bool) -> Path:
    """Download Uthmani text and save as quran_uthmani.json.

    Tries alquran.cloud API first, falls back to GitHub repo.
    Output: {"1": ["ayah1", "ayah2", …], "2": […], …}
    """
    out_path = output_dir / "quran_uthmani.json"
    if skip_existing and out_path.exists():
        log("  ⊘ Skipping quran_uthmani.json (already exists)")
        return out_path

    log("\n━━ Step 1/5 ━━ Quran Uthmanic Text")

    # Build ordered list of URLs to try
    urls = [ALQURAN_CLOUD["uthmani"]] + GITHUB_FALLBACKS["uthmani"]
    raw = download_json_with_fallbacks(urls)

    # Determine source format and extract flat structure
    if isinstance(raw, dict) and "data" in raw:
        # alquran.cloud API response
        data = extract_surah_texts_from_alquran(raw)
        log("  ✓ Data sourced from alquran.cloud API")
    elif isinstance(raw, dict) and len(raw) == 114:
        # GitHub flat format
        data = extract_surah_texts_from_github(raw)
        log("  ✓ Data sourced from GitHub fallback")
    else:
        raise ValueError(
            f"Unexpected data structure: root is {type(raw).__name__}, "
            f"keys={list(raw.keys())[:5] if isinstance(raw, dict) else 'N/A'}"
        )

    assert len(data) == 114, f"Expected 114 surahs, got {len(data)}"
    total_ayahs = sum(len(v) for v in data.values())
    log(f"  ✓ {total_ayahs:,} ayahs across {len(data)} surahs")

    save_json(out_path, data)
    return out_path


# ── Step 2: English Translation ───────────────────────────────────────


def download_english_translation(output_dir: Path, *, skip_existing: bool) -> Path:
    """Download English translation and save as quran_en_translation.json.

    Tries alquran.cloud API first (en.sahih), falls back to GitHub repo.
    Output: {"1": ["ayah1", "ayah2", …], "2": […], …}
    """
    out_path = output_dir / "quran_en_translation.json"
    if skip_existing and out_path.exists():
        log("  ⊘ Skipping quran_en_translation.json (already exists)")
        return out_path

    log("\n━━ Step 2/5 ━━ English Translation")

    urls = [ALQURAN_CLOUD["en_translation"]] + GITHUB_FALLBACKS["en_translation"]
    raw = download_json_with_fallbacks(urls)

    if isinstance(raw, dict) and "data" in raw:
        data = extract_surah_texts_from_alquran(raw)
        log("  ✓ Data sourced from alquran.cloud API (en.sahih)")
    elif isinstance(raw, dict) and len(raw) == 114:
        data = extract_surah_texts_from_github(raw)
        log("  ✓ Data sourced from GitHub fallback")
    else:
        raise ValueError("Unexpected data structure for English translation")

    assert len(data) == 114, f"Expected 114 surahs, got {len(data)}"
    save_json(out_path, data)
    return out_path


# ── Step 3: Surah Info ───────────────────────────────────────────────


def download_surah_info(output_dir: Path, *, skip_existing: bool) -> Path:
    """Download surah metadata from alquran.cloud and save as surah_info.json.

    The output is a JSON **array** (matching the app's ``parseSurahList``),
    with field names that ``SurahInfo.fromJson`` recognises.
    """
    out_path = output_dir / "surah_info.json"
    if skip_existing and out_path.exists():
        log("  ⊘ Skipping surah_info.json (already exists)")
        return out_path

    log("\n━━ Step 3/5 ━━ Surah Info")
    raw = download_json(ALQURAN_CLOUD["surah_info"])

    # alquran.cloud wraps: {"code": 200, "status": "OK", "data": […]}
    if isinstance(raw, dict) and "data" in raw:
        surahs_api = raw["data"]
    else:
        surahs_api = raw

    assert isinstance(surahs_api, list), "Surah info must be a list"
    assert len(surahs_api) == 114, f"Expected 114 surahs, got {len(surahs_api)}"

    # Map to fields expected by the Flutter SurahInfo model.
    surah_list = []
    for s in surahs_api:
        surah_num = s["number"]
        surah_list.append({
            "number": surah_num,
            "name_arabic": s["name"],
            "name_english": s.get("englishName", ""),
            "name_transliteration": s.get("englishNameTranslation", ""),
            "total_ayahs": s["numberOfAyahs"],
            "revelation_type": s["revelationType"],
            "revelation_order": s.get("revelationOrder", 0),
            "juz_start": compute_juz_for_ayah(surah_num, 1),
        })

    save_json(out_path, surah_list)
    return out_path


# ── Step 4: Word-by-Word Data ────────────────────────────────────────


def _build_word_by_word_from_uthmani(
    uthmani: dict[str, list[str]],
) -> dict[str, dict[str, dict[str, Any]]]:
    """Generate a basic word-by-word structure by splitting each ayah.

    Structure::

        {
          "surah_number": {
            "ayah_number": {
              "ayah_number": int,
              "surah_number": int,
              "words": [
                {
                  "number": int,          # globally unique word id
                  "ayah_number": int,
                  "word_number": int,     # globally unique
                  "word_position": int,   # position within ayah (1-based)
                  "text_arabic": str,
                  "text_transliteration": "",
                  "translation": null,
                  "root_letters": null,
                  "root_words": null,
                  "part_of_speech": null,
                  "morphology": null,
                  "grammar_note": null,
                },
                …
              ]
            }
          }
        }

    This matches the ``AyahWordAnalysis`` Dart model.
    """
    global_word_id = 0
    result: dict[str, dict[str, dict[str, Any]]] = {}

    for surah_str in sorted(uthmani.keys(), key=int):
        surah_num = int(surah_str)
        ayahs = uthmani[surah_str]
        surah_dict: dict[str, dict[str, Any]] = {}

        for ayah_idx, ayah_text in enumerate(ayahs, start=1):
            # Clean and split into tokens.
            cleaned = _clean_arabic_text(ayah_text)
            # Split on whitespace to get individual words/tokens.
            raw_tokens = cleaned.split()
            words = [t for t in raw_tokens if t]

            word_entries = []
            for pos, token in enumerate(words, start=1):
                global_word_id += 1
                word_entries.append({
                    "number": global_word_id,
                    "ayah_number": ayah_idx,
                    "word_number": global_word_id,
                    "word_position": pos,
                    "text_arabic": token,
                    "text_transliteration": "",
                    "translation": None,
                    "root_letters": None,
                    "root_words": None,
                    "part_of_speech": None,
                    "morphology": None,
                    "grammar_note": None,
                })

            surah_dict[str(ayah_idx)] = {
                "ayah_number": ayah_idx,
                "surah_number": surah_num,
                "words": word_entries,
            }

        result[surah_str] = surah_dict

    return result


def download_word_by_word(
    output_dir: Path,
    uthmani_path: Path,
    *,
    skip_existing: bool,
) -> Path:
    """Download or generate word-by-word data and save as quran_word_by_word.json."""
    out_path = output_dir / "quran_word_by_word.json"
    if skip_existing and out_path.exists():
        log("  ⊘ Skipping quran_word_by_word.json (already exists)")
        return out_path

    log("\n━━ Step 4/5 ━━ Word-by-Word Data")

    word_data: dict[str, dict[str, dict[str, Any]]] | None = None

    # Try downloading the pre-built word-by-word file first.
    try:
        raw = download_json(WORD_BY_WORD_URL)
        if isinstance(raw, dict):
            first_key = next(iter(raw), None)
            if first_key and first_key.isdigit():
                word_data = raw
                log("  ✓ Downloaded pre-built word-by-word data")
            else:
                log("  ⚠ Downloaded file has unexpected structure; "
                    "will generate from Uthmani text")
        else:
            log("  ⚠ Downloaded file is not a dict; "
                "will generate from Uthmani text")
    except RuntimeError:
        log("  ⚠ Could not download word-by-word data; "
            "generating from Uthmani text …")

    if word_data is None:
        log("  Loading Uthmani text to generate word-by-word data …")
        with open(uthmani_path, "r", encoding="utf-8") as fh:
            uthmani = json.load(fh)
        word_data = _build_word_by_word_from_uthmani(uthmani)

        total_words = sum(
            len(ayah_data.get("words", []))
            for surah in word_data.values()
            for ayah_data in surah.values()
        )
        log(f"  ✓ Generated word-by-word data for {len(word_data)} surahs "
            f"({total_words:,} total words)")

    save_json(out_path, word_data)
    return out_path


# ── Step 5: Summary & Validation ─────────────────────────────────────


def validate_outputs(output_dir: Path) -> None:
    """Lightweight sanity checks on all generated files."""
    log("\n━━ Step 5/5 ━━ Validation")

    files: dict[str, Any] = {
        "quran_uthmani.json": lambda d: (
            isinstance(d, dict) and len(d) == 114
        ),
        "quran_en_translation.json": lambda d: (
            isinstance(d, dict) and len(d) == 114
        ),
        "surah_info.json": lambda d: (
            isinstance(d, list) and len(d) == 114
        ),
        "quran_word_by_word.json": lambda d: (
            isinstance(d, dict) and len(d) == 114
        ),
    }

    all_ok = True
    for filename, check in files.items():
        path = output_dir / filename
        if not path.exists():
            log(f"  ✗ {filename} – MISSING")
            all_ok = False
            continue

        try:
            with open(path, "r", encoding="utf-8") as fh:
                data = json.load(fh)
            if check(data):
                log(f"  ✓ {filename} – valid")
            else:
                log(f"  ✗ {filename} – structure mismatch")
                all_ok = False
        except Exception as exc:  # noqa: BLE001
            log(f"  ✗ {filename} – {exc}")
            all_ok = False

    if all_ok:
        log("\n  🎉 All files validated successfully!")
    else:
        log("\n  ⚠  Some files have issues — review the errors above.")
        sys.exit(1)


# ── CLI ───────────────────────────────────────────────────────────────


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Download and prepare Quran/Hadith JSON data for the Flutter app.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=DEFAULT_OUTPUT_DIR,
        help=f"Output directory (default: {DEFAULT_OUTPUT_DIR.relative_to(PROJECT_ROOT)})",
    )
    parser.add_argument(
        "--skip-existing",
        action="store_true",
        help="Skip downloading files that already exist on disk.",
    )
    parser.add_argument(
        "--uthmani-only",
        action="store_true",
        help="Only download the Uthmani Quran text (step 1).",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    output_dir = args.output_dir.resolve()

    log("Quran & Hadith Data Preparation")
    log(f"Output directory: {output_dir}")
    log(f"Project root:     {PROJECT_ROOT}")

    output_dir.mkdir(parents=True, exist_ok=True)

    # Step 1 — always runs
    uthmani_path = download_uthmani(output_dir, skip_existing=args.skip_existing)

    if args.uthmani_only:
        log("\n--uthmani-only flag set; stopping after step 1.")
        return

    # Step 2
    download_english_translation(output_dir, skip_existing=args.skip_existing)

    # Step 3
    download_surah_info(output_dir, skip_existing=args.skip_existing)

    # Step 4
    download_word_by_word(
        output_dir, uthmani_path, skip_existing=args.skip_existing
    )

    # Step 5
    validate_outputs(output_dir)

    log("\nDone.")


if __name__ == "__main__":
    main()
