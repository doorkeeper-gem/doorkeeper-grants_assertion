# Doorkeeper - Assertion Grant Extension

Assertion grant extension for Doorkeeper. Born from:
https://github.com/doorkeeper-gem/doorkeeper/pull/249

## Installation

1. Add both gems to your `Gemfile`.
2. Add `assertion` as a `grant_flow` to your initializer.

___

Lets you define your own way of authenticating resource owners via 3rd Party
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
___

IETF standard: http://tools.ietf.org/html/draft-ietf-oauth-assertions-16
