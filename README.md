# ActiveAws

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activeaws'
```

If you want to load this library automatically with `Bundler.require`, please specify `require` option at Gemfile.

```ruby
gem 'activeaws', require: 'active_aws'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activeaws

## Usage

```ruby
require 'active_aws'
```

### Initialize

```rb
ActiveAws::Base.load_config!(
  region: 'ap-northeast-1',
  profile: 'rv-metheglin',
)
```

```rb
ActiveAws::Base.load_config!( File.expand_path("./aws.yml", __dir__) )
```

### Ec2

```rb
provisioner = ActiveAws::Ec2Provisioner.new(:test_instance_name) do |e|
  e.instance_type = 't2.nano'
  e.key_name = 'your-credential-key-name-here'
  e.image_id = 'ami-xxxxxx'
  e.security_group_ids = ['sg-xxxxxxx']
  e.subnet_id = 'subnet-xxxxxxx'
end
ec2 = provisioner.exec!
ec2.wait_until :instance_running
```

```rb
ec2 = ActiveAws::Ec2.find( 'your-instance-id' )
ec2.to_h
```

### CloudFormation

```rb
# Prepare `vpc.json` with like:
# Ex): https://aws-quickstart.s3-ap-northeast-1.amazonaws.com/quickstart-linux-bastion/submodules/quickstart-aws-vpc/templates/aws-vpc.template
class VpcProduction < ActiveAws::CloudFormationProvisioner

  class << self
    def generate
      new(
        "your-cloudformation-stack-name-here",
        File.expand_path("vpc.json", __dir__),
        {
          "AvailabilityZones"   => "ap-northeast-1a,ap-northeast-1c,ap-northeast-1d",
          "KeyPairName"         => "your-credential-key-name-here",
          "PrivateSubnet1CIDR"  => "10.0.0.0/19",
          "PrivateSubnet2CIDR"  => "10.0.32.0/19",
          "PublicSubnet1CIDR"   => "10.0.128.0/20",
          "PublicSubnet2CIDR"   => "10.0.144.0/20",
          "RemoteAccessCIDR"    => "0.0.0.0/0",
          "VPCCIDR"             => "10.0.0.0/16",
        }
      )
    end
  end

  # # Please carefully use this method!! 
  # # The CloudFormationProvisioner class doesn't implement `destroy!` on purpose.
  # def destroy!
  #   self.class.client.delete_stack(stack_name: normalized_name)
  # end

end
```

```rb
prov = VpcProduction.generate
prov.save!
prov.wait_until :stack_create_complete
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/metheglin/activeaws.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
