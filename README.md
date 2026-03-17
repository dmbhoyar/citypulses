# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

Quick start (local / server):

1. Install Ruby (use rbenv/rvm) matching project (e.g. 3.1+)
2. Install bundler and gems:

```bash
gem install bundler
bundle install
```

3. Create and migrate DB, then seed:

```bash
bin/rails db:create db:migrate
bin/rails db:seed
```

4. Run imports (optional):

```bash
bin/rails imports:news
bin/rails imports:agmarknet
bin/rails imports:govjobs
```

5. Start server:

```bash
bin/rails server
```

Notes:
- The environment used for development must have Ruby and system libs installed; this workspace runner cannot execute Ruby.
- Use `whenever` or server cron to run `ImportsJob.perform_later` daily (schedule.rb included).

Stripe (optional):
- To enable Stripe Checkout, set `STRIPE_SECRET_KEY` and `STRIPE_PUBLISHABLE_KEY` in your environment.
- The app will fall back to a demo local subscription when keys are not present.

Webhooks and demo mode:
- To accept real Stripe webhooks, set `STRIPE_ENDPOINT_SECRET` (the signing secret from Stripe dashboard) and configure your webhook URL to POST to `/webhooks/stripe`.
- For development or a free/demo mode (no Stripe account required), set `WEBHOOK_ALLOW_DEMO=1` or set `WEBHOOK_DEMO_SECRET` and send requests with header `X-DEMO-SIGNATURE: <WEBHOOK_DEMO_SECRET>`; the webhook controller will accept and process `checkout.session.completed` events from JSON payloads.

Example demo webhook payload (POST /webhooks/stripe):

```json
{
	"type": "checkout.session.completed",
	"data": {
		"object": {
			"id": "cs_test_demo",
			"metadata": { "subscription_id": "123" },
			"amount_total": 100000
		}
	}
}
```


Install cron entries (whenever):

```bash
gem install whenever
whenever --update-crontab
```

If you want me to add CI (GitHub Actions) or a Stripe webhook handler, tell me which provider and I will scaffold it.

