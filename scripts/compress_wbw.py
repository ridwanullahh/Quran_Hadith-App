#!/usr/bin/env python3
"""Compress quran_word_by_word.json (~33MB) to quran_wbw.json (<2MB).

The original file stores per-word JSON objects with many null fields.
This script extracts only the Arabic word text and stores it as:
    {"surah_num": {"ayah_num": ["word1", "word2", ...], ...}, ...}
"""

import json
import os
import sys

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(BASE_DIR, 'assets', 'data', 'quran_word_by_word.json')
DST = os.path.join(BASE_DIR, 'assets', 'data', 'quran_wbw.json')


def main():
    print(f"Reading {SRC} ...")
    with open(SRC, 'r', encoding='utf-8') as f:
        data = json.load(f)

    compressed = {}
    total_words = 0
    total_ayahs = 0

    for surah_str, ayahs in data.items():
        surah_data = {}
        for ayah_str, ayah_obj in ayahs.items():
            words = ayah_obj.get('words', [])
            word_texts = [w['text_arabic'] for w in words if 'text_arabic' in w]
            surah_data[ayah_str] = word_texts
            total_words += len(word_texts)
            total_ayahs += 1
        compressed[surah_str] = surah_data

    print(f"Writing {DST} ...")
    with open(DST, 'w', encoding='utf-8') as f:
        json.dump(compressed, f, ensure_ascii=False, separators=(',', ':'))

    src_size = os.path.getsize(SRC)
    dst_size = os.path.getsize(DST)
    ratio = dst_size / src_size * 100

    print(f"Done!")
    print(f"  Surahs:        {len(compressed)}")
    print(f"  Ayahs:         {total_ayahs}")
    print(f"  Total words:   {total_words}")
    print(f"  Original size: {src_size / 1_048_576:.1f} MB")
    print(f"  Compressed:    {dst_size / 1_048_576:.1f} MB  ({ratio:.1f}%)")


if __name__ == '__main__':
    main()
