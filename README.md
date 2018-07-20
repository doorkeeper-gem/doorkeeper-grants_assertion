# Doorkeeper - Assertion Grant Extension

[![Travis CI](https://img.shields.io/travis/doorkeeper-gem/doorkeeper-grants_assertion/master.svg)](https://travis-ci.org/doorkeeper-gem/doorkeeper-grants_assertion)

Assertion grant extension for Doorkeeper. Born from:
https://github.com/doorkeeper-gem/doorkeeper/pull/249

## Installation

1. Add both gems to your `Gemfile`.
2. Add `assertion` as a `grant_flow` to your initializer. There are multiple ways to use it:
  - Reuse devise configuration (returns OmniAuth AuthHash)
  - Direct Omniauth configuration (returns OmniAuth AuthHash)
  - Other Alternatives (they are not OmniAuth AuthHash compatible)

___



### Reuse devise configuration

Will automagically load the OmniAuth configs from Devise, and will return a OmniAuth AuthHash.
NOTE: `server.client` will authenticate your client, if you dont need it delete `server.client` from the if.

```ruby
Doorkeeper.configure do
  resource_owner_from_assertion do
    if server.client && params[:provider] && params[:assertion]
      auth = Doorkeeper::GrantsAssertion::Devise::OmniAuth.auth_hash(
        provider: params.fetch(:provider),
        assertion: params.fetch(:assertion)
      )
      User.where(email: auth.info.email).first if auth
    end
  end
  # add your supported grant types and other extensions
  grant_flows %w(assertion authorization_code implicit password client_credentials)
end
```

### Direct Omniauth configuration

Reuses OmniAuth strategy implementation, such as facebook or google.
This allows you to use the auth_hash, which will return a OmniAuth AuthHash
NOTE: `server.client` will authenticate your client, if you dont need it delete `server.client` from the if.

```ruby
Doorkeeper.configure do
  resource_owner_from_assertion do
    if server.client && params[:provider] && params[:assertion]
      case params.fetch(:provider)
      when "google"
        auth = Doorkeeper::GrantsAssertion::OmniAuth.oauth2_wrapper(
          provider: "google",
          strategy_class: OmniAuth::Strategies:::GoogleOauth2,
          client_id: ENV["GOOGLE_CLIENT_ID"],
          client_secret: ENV["GOOGLE_CLIENT_SECRET"],
          client_options: { skip_image_info: false },
          assertion: params.fetch(:assertion)
        ).auth_hash rescue nil
        unless auth.nil?
          # your custom finders - just like in devise omniauth
          User.find_by(google_id: auth['id'])
        end
      end
    end
  end
  # add your supported grant types and other extensions
  grant_flows %w(assertion authorization_code implicit password client_credentials)
end
```

### Other Alternatives

Also, lets you define your own way of authenticating resource owners via 3rd Party
applications. For example, via Facebook:

```ruby
Doorkeeper.configure do
  resource_owner_from_assertion do
    facebook = URI.parse('https://graph.facebook.com/me?access_token=' +
    params[:assertion])
    response = Net::HTTP.get_response(facebook)
    user_data = JSON.parse(response.body)
    User.find_by_facebook_id(user_data['id'])
  end

  # add your supported grant types and other extensions
  grant_flows %w(assertion authorization_code implicit password client_credentials)
end
```

If you want to ensure that resource owners can only receive access tokens scoped to a specific application, you'll need to add that logic in to the definition as well:

```ruby
Doorkeeper.configure do
  resource_owner_from_assertion do
    Doorkeeper::Application.find_by!(uid: params[:client_id]) #will raise an exception if not found
    facebook = URI.parse('https://graph.facebook.com/me?access_token=' +
    params[:assertion])
    ....continue with authentication lookup....
```
More complete examples, also for other providers may be found in the [wiki](https://github.com/doorkeeper-gem/doorkeeper-grants_assertion/wiki).
___

IETF standard: http://tools.ietf.org/html/rfc7521

## Supported versions

Assertion grant extension for Doorkeeper is tested with Rails 4.2 and 5.0.

## Contributing

After adding the feature and funtionality, please run
```
 bundle exec appraisal install
```

This will update gems in for travis ci tests.
