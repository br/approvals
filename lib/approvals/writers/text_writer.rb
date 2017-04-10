module Approvals
  module Writers
  end
end

class Approvals::Writers::TextWriter

  def initialize(options)
    @options = options
  end

  def extension
    'txt'
  end

  def write(data, path)
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, 'w') do |f|
      f.write format(data)
    end
  end

  def format(data)
    data.to_s
  end

  def filter(data)
    data
  end

end