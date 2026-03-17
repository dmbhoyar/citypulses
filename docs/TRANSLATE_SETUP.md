Local offline translation service (no Docker)

Overview
--------
This project includes a tiny Flask microservice that uses Argos Translate to provide an HTTP /translate endpoint compatible with the app's TranslateClient. Run it locally to get free, no-rate-limit translation.

When to use
-----------
- You don't want Docker
- You want translations on your machine or on a VM you control
- You accept installing Python packages and Argos models locally

Steps (quick)
-------------
1. Create a virtualenv and install dependencies

```bash
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install flask argostranslate
```

2. Install Argos language packages

Argos ships language models as `.argosmodel` files. Visit https://www.argosopentech.com/ to find models. Download the model file(s) you need (for example `en-mr.argosmodel` for English↔Marathi), then install:

```bash
python - <<'PY'
from argostranslate import package
package.install_from_path('path/to/en-mr.argosmodel')
PY
```

Repeat for each pair you need (en->hi, en->mr, etc.).

3. Start the service

```bash
FLASK_APP=scripts/argos_translate_service.py flask run --port=5001
```

4. Point the Rails app to the service

Set these environment variables for your Rails process (e.g., in `.env` or your systemd/unit):

```
ENABLE_TRANSLATION=1
TRANSLATE_URL=http://127.0.0.1:5001
```

Restart the Rails server. The `TranslateClient` will POST to `/translate` on the configured host and return translated text.

Notes
-----
- Model availability: not every language pair may have a ready Argos model. If a pair is missing, you can chain two translations (e.g., en->hi via en->es + es->hi) but quality varies.
- If Argos is not suitable for a language, you can fallback to a cloud provider (Google Translate) but that requires API keys.
- This approach runs entirely on your host, so there are no external rate limits beyond your server resources.

If you'd like, I can also:
- Add a `docker-compose.yml` (you said no Docker, so skipped it)
- Add a small systemd unit or run script to make starting the service one command
- Provide a small UI toggle to enable/disable translation per user
