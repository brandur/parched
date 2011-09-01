module Skine
  class Blob < Grit::Blob
    attr_reader :path

    def initialize(blob, atts)
      blob.instance_variables.each do |v|
        instance_variable_set(v, blob.instance_variable_get(v))
      end
      atts.each do |k, v|
        instance_variable_set("@#{k}".to_sym, v)
      end
    end

    def last_commit
      @repo.log('master', path, :max_count => 1).first
    end
  end
end
