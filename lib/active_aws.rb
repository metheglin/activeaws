require "active_aws/version"

require 'aws-sdk'
require 'active_support'
require 'active_support/core_ext'

require_relative 'active_aws/configure'
require_relative 'active_aws/base'
require_relative 'active_aws/tag_spec'
require_relative 'active_aws/ec2'
require_relative 'active_aws/ec2_provisioner'
require_relative 'active_aws/cloud_formation_provisioner'
require_relative 'active_aws/elastic_load_balancing_v2'
require_relative 'active_aws/target_group'

module ActiveAws
end
