module Approvals
  class Filter
    attr_reader :filters

    def initialize(filters)
      @filters = filters
      @paths_cache = {}
    end

    def apply(hash_or_array)
      if @filters.any?
        censored(hash_or_array)
      else
        hash_or_array
      end
    end

    def censored(value, path=nil)
      if value.nil?
        nil
      elsif path && filtered?(path)
        "<filtered value>"
      else
        case value
          when Array
            value.map { |item| censored(item) }
          when Hash
            pairs = value.map do |inner_key, inner_value|
              [inner_key, censored(inner_value, "#{path}:#{inner_key}")]
            end
            Hash[pairs]
          else
            value
        end
      end
    end

    def filtered?(path)
      return @paths_cache[path] if @paths_cache.key? path

      filters.each do |filter|
        next unless path.match(filter)
        @paths_cache[path] = true
        return true
      end
      @paths_cache[path] = false
    end
  end
end
