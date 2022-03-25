# frozen_string_literal: true

require "prime"
require_relative "sharing/version"
require "hensel_code"

# module secret sharing
module Sharing
  class Error < StandardError; end

  # autoload :CRTAsmuthBloomV2, "sharing/crt_asmuth_bloom_v2"

  # module for polynomial-based features
  module Polynomial
    autoload :Tools, "sharing/polynomial/tools"
    module Shamir
      autoload :V1, "sharing/polynomial/shamir/v1"
    end
  end

  module CRT
    module AsmuthBloom
      autoload :V2, "sharing/crt/asmuth-bloom/v2"
    end
  end
end
