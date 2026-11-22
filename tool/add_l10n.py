"""Adds l10n keys to app_en.arb + app_ar.arb.

Usage: python tool/add_l10n.py tool/l10n_batch_x.py
The batch file defines NEW = { key: (en, ar, {placeholder: type} | None) }.
Existing keys are skipped. Run `flutter gen-l10n` afterwards.
"""
import collections
import json
import os
import runpy
import sys

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
batch = runpy.run_path(sys.argv[1])['NEW']
for lang, idx in (('en', 0), ('ar', 1)):
    path = os.path.join(root, 'lib', 'l10n', f'app_{lang}.arb')
    d = json.load(open(path, encoding='utf-8'), object_pairs_hook=collections.OrderedDict)
    added = 0
    for k, v in batch.items():
        if k in d:
            continue
        d[k] = v[idx]
        added += 1
        if v[2] and lang == 'en':
            d['@' + k] = {'placeholders': {p: {'type': t} for p, t in v[2].items()}}
    json.dump(d, open(path, 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
    print(lang, 'added', added)
