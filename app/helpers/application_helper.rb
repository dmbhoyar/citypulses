module ApplicationHelper
	# Safe image helper: try asset pipeline first, fall back to a static /assets/ path
	def safe_image_tag(source, **opts)
		begin
			image_tag(source, **opts)
		rescue => e
			# If Propshaft/asset pipeline can't find the asset, fall back to a static path
			src = source.to_s.start_with?('/') ? source : File.join('/assets', source)
			attrs = {}
			attrs[:src] = src
			attrs[:alt] = opts[:alt] || ''
			attrs[:width] = opts[:width] if opts[:width]
			attrs[:height] = opts[:height] if opts[:height]
			# build attribute string safely
			attr_str = attrs.map { |k, v| %(#{k}="#{ERB::Util.html_escape(v)}") }.join(' ')
			("<img #{attr_str} />").html_safe
		end
	end

	# Translate text using TranslateClient when ENABLE_TRANSLATION=1
	# Caches translations per-locale and text.
	def translate_api_text(text)
		return text.to_s if text.to_s.strip.empty?
		return text.to_s unless ENV['ENABLE_TRANSLATION'] == '1'
		cache_key = "translate:#{I18n.locale}:#{Digest::MD5.hexdigest(text.to_s)}"
		Rails.cache.fetch(cache_key, expires_in: 12.hours) do
			TranslateClient.translate(text.to_s, target: I18n.locale.to_s)
		end
	rescue => e
		Rails.logger.warn "translate_api_text failed: #{e.class} #{e.message}"
		text.to_s
	end

	# Lightweight domain translation: try to map common commodity/variety names
	# to keys in the locale files under `commodities` or `varieties`.
	def translate_domain_text(text)
		return text.to_s if text.to_s.blank?
		key = text.to_s.downcase.gsub(/[^a-z0-9]+/i, ' ').strip.gsub(/\s+/, '_')
		# try commodities then varieties
		translated = I18n.exists?("commodities.#{key}") ? I18n.t("commodities.#{key}") : nil
		return translated if translated.present?
		translated = I18n.exists?("varieties.#{key}") ? I18n.t("varieties.#{key}") : nil
		return translated.present? ? translated : text.to_s
	end

	# Return a Google Translate URL for an article so users can view a translated page
	def external_translate_url(original_url, target_locale = I18n.locale)
		return nil if original_url.blank?
		# Use Google Translate web UI
		"https://translate.google.com/translate?sl=auto&tl=#{ERB::Util.url_encode(target_locale.to_s)}&u=#{ERB::Util.url_encode(original_url)}"
	end
end
