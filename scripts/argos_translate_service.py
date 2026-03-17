#!/usr/bin/env python3
"""
Lightweight translation microservice using Argos Translate (offline).

Usage (recommended):

  python3 -m venv venv
  source venv/bin/activate
  pip install --upgrade pip
  pip install flask argostranslate

Before starting, install the language packages you need. Example (english->marathi/hindi):

  # download model packages from https://www.argosopentech.com/ and save locally
  python3 -c "from argostranslate import package; import sys; package.install_from_path('path/to/argospackage.argosmodel')"

Start service:
  FLASK_APP=scripts/argos_translate_service.py flask run --port=5001

This exposes POST /translate with JSON { q, source, target } returning { translatedText }.
"""
from flask import Flask, request, jsonify
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

try:
    from argostranslate import translate as argostranslate_translate
except Exception:
    argostranslate_translate = None


@app.route('/translate', methods=['POST'])
def translate():
    data = request.get_json(force=True)
    q = data.get('q') or ''
    source = data.get('source', 'auto')
    target = data.get('target', 'en')
    if not q:
        return jsonify({'translatedText': ''})
    if argostranslate_translate is None:
        app.logger.warning('Argos Translate not installed')
        return jsonify({'translatedText': q})
    try:
        # Argos Translate expects language codes like 'en', 'mr'
        translated = argostranslate_translate.translate(q, source, target)
        return jsonify({'translatedText': translated})
    except Exception as e:
        app.logger.exception('translation failed')
        return jsonify({'translatedText': q})


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5001)
