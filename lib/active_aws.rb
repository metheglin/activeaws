require "active_aws/version"

require 'aws-sdk'
require 'active_support'
require 'active_support/core_ext'

require_relative 'active_aws/configure'
require_relative 'active_aws/base'
require_relative 'active_aws/base_resource'
require_relative 'active_aws/tag_spec'
require_relative 'active_aws/ec2'
require_relative 'active_aws/ec2_provisioner'
require_relative 'active_aws/cloud_formation_provisioner'
require_relative 'active_aws/elastic_load_balancing_v2'
require_relative 'active_aws/target_group'
require_relative 'active_aws/vpc'
require_relative 'active_aws/subnet'
require_relative 'active_aws/s3_bucket'
require_relative 'active_aws/key_pair'
require_relative 'active_aws/rds_cluster'
require_relative 'active_aws/security_group'

module ActiveAws
end
