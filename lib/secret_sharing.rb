# frozen_string_literal: true

require_relative "secret_sharing/version"
require "hensel_code"

# module secret sharing
module SecretSharing
  class Error < StandardError; end

  autoload :CRTAsmuthBloomV1, "secret_sharing/crt_asmuth_bloom_v1"
end
