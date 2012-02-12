require 'rspec/expectations/errors'
require 'rspec/approvals/empty_approval'

module RSpec
  module Approvals

    class ReceivedDiffersError < RSpec::Expectations::ExpectationNotMetError; end

    class Approval

      class << self
        def normalize(s)
          s.gsub(/[\W]/, ' ').strip.squeeze(" ").gsub(' ', '_').downcase
        end

        def base_path(s)
          Approvals.path + normalize(s)
        end
      end

      attr_reader :location, :name, :options, :path, :writer

      def initialize(example, received = '', options = {})
        @name = Approval.normalize(example.full_description)
        @path = Approvals.path + name
        @options = options

        example.options[:approval] = true
        example.options[:approval_diff_paths] = {
          :received => received_path,
          :approved => approved_path,
        }
        @writer = Writer.new(self)

        @writer.write(:approved, EmptyApproval.new) unless File.exists?(approved_path)
        @writer.write(:received, received)
      end

      def approved_path
        "#{@path}.approved.txt"
      end

      def received_path
        "#{@path}.received.txt"
      end

      def failure_message
        <<-FAILURE_MESSAGE

        Approval Failure:
          The received contents did not match the approved contents.

        Inspect the differences in the following files:
        #{received_path}
        #{approved_path}

        FAILURE_MESSAGE
      end

      def location=(backtrace)
        @location = [backtrace.first.gsub(Dir.pwd, '.').gsub(/:in\ .*$/, '')]
      end

      def verify
        if FileUtils.cmp(received_path, approved_path)
          File.unlink(received_path)
        else
          Dotfile.append(diff_path)
          raise RSpec::Approvals::ReceivedDiffersError, failure_message, location
        end
      end

      def diff_path
        "#{received_path} #{approved_path}"
      end

      def approved
        File.read(approved_path)
      end

      def received
        File.read(received_path)
      end
    end
  end
end
