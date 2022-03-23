# frozen_string_literal: true

require 'prime'
require_relative 'secret_sharing/version'
require 'hensel_code'

# module secret sharing
module SecretSharing
  class Error < StandardError; end

  # autoload :CRTAsmuthBloomV2, "secret_sharing/crt_asmuth_bloom_v2"

  module Polynomial
    module Shamir
      autoload :V1, "secret_sharing/polynomial/shamir/v1"
    end
  end

  module CRT
    module AsmuthBloom
      autoload :V2, "secret_sharing/crt/asmuth-bloom/v2"
    end
  end
end
