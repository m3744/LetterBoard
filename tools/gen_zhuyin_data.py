#!/usr/bin/env python3
"""從新酷音詞庫（libchewing-data）產生 App 需要的兩份資料檔。

用法：
    git clone --depth 1 https://github.com/chewing/libchewing-data /tmp/libchewing-data
    python3 tools/gen_zhuyin_data.py /tmp/libchewing-data/dict/chewing

產出（放在 LetterBoard/Resources/）：
    zhuyin_readings.tsv  注音音節 → 代表字（做法 A：朗讀時把注音換成讀音唯一的字）
    lexicon.tsv          注音鍵 → 字詞 → 分數（給 Megrez 選字引擎用）

注音鍵的格式：每個音節是「聲母 介音 韻母 聲調」，一聲不寫聲調符號；
多音節之間用 "-" 連接，例如 "ㄋㄧˇ-ㄏㄠˇ"。
"""

import csv
import math
import sys
from collections import defaultdict
from pathlib import Path

# 詞長超過這個值的詞條不收，控制檔案大小（Megrez 預設最大段長是 10）。
MAX_PHRASE_LENGTH = 6
# 一個字在某個讀音的頻率占它所有讀音頻率的比例，達到這個值才算「這個讀音的代表字」。
DOMINANT_RATIO = 0.9

ZHUYIN_SYMBOLS = set("ㄅㄆㄇㄈㄉㄊㄋㄌㄍㄎㄏㄐㄑㄒㄓㄔㄕㄖㄗㄘㄙㄧㄨㄩㄚㄛㄜㄝㄞㄟㄠㄡㄢㄣㄤㄥㄦ")
TONE_MARKS = set("ˊˇˋ˙")


def read_csv(path):
    with open(path, encoding="utf-8") as f:
        for row in csv.reader(f):
            if not row or row[0].startswith("#") or len(row) != 3:
                continue
            value, freq, reading = row
            yield value, int(freq), reading.split(" ")


def is_valid_syllable(syllable):
    return syllable and all(ch in ZHUYIN_SYMBOLS or ch in TONE_MARKS for ch in syllable)


def is_han(value):
    return all(not (ch in ZHUYIN_SYMBOLS or ch in TONE_MARKS) for ch in value)


def main(dict_dir):
    dict_dir = Path(dict_dir)
    out_dir = Path(__file__).resolve().parent.parent / "LetterBoard" / "Resources"

    # word.csv：每個字的所有讀音（頻率都是 0，只用來知道有哪些讀音）
    char_readings = defaultdict(set)
    all_syllables = set()
    for value, _, reading in read_csv(dict_dir / "word.csv"):
        if len(reading) != 1 or not is_valid_syllable(reading[0]) or not is_han(value):
            continue
        char_readings[value].add(reading[0])
        all_syllables.add(reading[0])

    # tsi.csv：字與詞的頻率
    entries = {}
    char_freq = defaultdict(lambda: defaultdict(int))
    for value, freq, reading in read_csv(dict_dir / "tsi.csv"):
        if len(reading) != len(value) or not all(map(is_valid_syllable, reading)) or not is_han(value):
            continue
        if len(value) > MAX_PHRASE_LENGTH:
            continue
        key = "-".join(reading)
        entries[(key, value)] = max(entries.get((key, value), 0), freq)
        if len(value) == 1:
            char_freq[value][reading[0]] = max(char_freq[value][reading[0]], freq)

    # 單字只在 word.csv 出現、tsi.csv 沒有的讀音，也補進詞庫，確保每個音節都打得出字
    for char, readings in char_readings.items():
        for syllable in readings:
            entries.setdefault((syllable, char), 0)

    # ---- zhuyin_readings.tsv ----
    readings_out = {}
    for syllable in sorted(all_syllables):
        best = None
        for char, readings in char_readings.items():
            if syllable not in readings:
                continue
            freqs = char_freq.get(char, {})
            freq = freqs.get(syllable, 0)
            total = sum(freqs.values())
            # 讀音唯一，或這個讀音占絕大多數，才算「不會被唸錯」
            unambiguous = len(readings) == 1 or (total > 0 and freq / total >= DOMINANT_RATIO)
            rank = (unambiguous, freq)
            if best is None or rank > best[0]:
                best = (rank, char)
        if best:
            readings_out[syllable] = best[1]

    with open(out_dir / "zhuyin_readings.tsv", "w", encoding="utf-8") as f:
        f.write("# 注音音節\t代表字（由 tools/gen_zhuyin_data.py 從 libchewing-data 產生，LGPL-2.1-or-later）\n")
        for syllable, char in readings_out.items():
            f.write(f"{syllable}\t{char}\n")

    # ---- lexicon.tsv ----
    # 分數用 log10 機率（和 Megrez / vChewing 的慣例一致），頻率 0 的給一個很低的分數
    total = sum(entries.values()) or 1
    floor = math.log10(0.5 / total)
    with open(out_dir / "lexicon.tsv", "w", encoding="utf-8") as f:
        f.write("# 注音鍵\t字詞\t分數（由 tools/gen_zhuyin_data.py 從 libchewing-data 產生，LGPL-2.1-or-later）\n")
        for (key, value), freq in sorted(entries.items()):
            score = math.log10(freq / total) if freq > 0 else floor
            f.write(f"{key}\t{value}\t{score:.3f}\n")

    print(f"syllables: {len(all_syllables)}, readings: {len(readings_out)}, lexicon entries: {len(entries)}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    main(sys.argv[1])
