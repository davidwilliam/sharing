# frozen_string_literal: true

require_relative "secret_sharing/version"
require 'hensel_code'

module SecretSharing
  class Error < StandardError; end
  
  autoload  :CRT, "secret_sharing/crt"
end
