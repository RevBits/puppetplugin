# RevBits - Puppet Plugin

## Environment Setup

Install `aes-everywhere` gem on **puppet-agent** with the following command.

```ruby
/opt/puppetlabs/puppet/bin/gem install aes-everywhere
```

## Example Usage

```ruby
$secret_value = Deferred(puppetplugin::secret, ['KEY_TO_FETCH', {
  appliance_url => "https://appliance-url.com",
  api_key => Sensitive("YourAPIKey") 
}])
```

The above `puppet` function returns your secret wrapped in `Sensitive` datatype. To `unwrap` use the following code.

```ruby
$secret_value.call.unwrap
```