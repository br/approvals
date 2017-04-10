require 'approvals/writers/text_writer'
require 'approvals/writers/array_writer'
require 'approvals/writers/hash_writer'
require 'approvals/writers/html_writer'
require 'approvals/writers/xml_writer'
require 'approvals/writers/json_writer'
require 'approvals/writers/binary_writer'

module Approvals
  module Writer
    extend Writers

    REGISTRY = {
      json: Writers::JsonWriter,
      xml: Writers::XmlWriter,
      html: Writers::HtmlWriter,
      hash: Writers::HashWriter,
      array: Writers::ArrayWriter,
      txt: Writers::TextWriter,
    }


    class << self
      def for(format)
        begin
          REGISTRY[format] || Object.const_get(format)
        rescue NameError => e
          error = ApprovalError.new(
            "Approval Error: #{ e }. Please define a custom writer as outlined"\
            " in README section 'Customizing formatted output': "\
            "https://github.com/kytrinyx/approvals#customizing-formatted-output"
          )
          raise error
        end
      end
    end

  end
end
