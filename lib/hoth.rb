require "hoth/version"
require 'singleton'

require 'active_support/inflector'
require 'active_support/core_ext/module/attribute_accessors'

require 'hoth/transport/hoth_transport'
require 'hoth/transport/json_transport'

require 'hoth/definition'
require 'hoth/deployment_module'
require 'hoth/endpoint'
require 'hoth/service'
require 'hoth/service_deployment'
require 'hoth/service_registry'
require 'hoth/services'

require 'hoth/util/logger'

require 'hoth/extension/core/exception'
require 'hoth/exceptions'

module Hoth
  module Config
    mattr_accessor :timeout
  end
end
