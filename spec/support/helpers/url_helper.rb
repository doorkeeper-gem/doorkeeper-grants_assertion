module UrlHelper
  def assertion_endpoint_url(options = {})
    parameters = {
      code:          options[:code],
      client_id:     options[:client_id]     || options[:client].uid,
      client_secret: options[:client_secret] || options[:client].secret,
      redirect_uri:  options[:redirect_uri]  || options[:client].redirect_uri,
      grant_type:    options[:grant_type]    || "assertion",
      assertion:     options[:assertion]     || default_assertion(options)
    }
    parameters.merge!(provider: options[:provider]) if options[:provider]
    "/oauth/token?#{build_query(parameters)}"
  end

  def build_query(hash)
    Rack::Utils.build_query(hash)
  end

  def default_assertion(options)
    (options[:resource_owner] ? options[:resource_owner].assertion : nil)
  end
end

RSpec.configuration.send :include, UrlHelper, type: :request
