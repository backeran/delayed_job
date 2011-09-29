class ActiveRecord::Base
  yaml_as "tag:ruby.yaml.org,2002:ActiveRecord"

  def self.yaml_new(klass, tag, val)
    find_for_delayed_job(klass, val['attributes'][klass.primary_key])
  end

  def init_with(coder)
    find_for_delayed_job(self.class, coder.map['attributes'][self.class.primary_key])
  end

  def encode_with(coder)
    coder['attributes'] = attributes
    self
  end

  # undef_method :encode_with

  def to_yaml_properties
    ['@attributes']
  end

private

  def find_for_delayed_job(klass, id)
    if ActiveRecord::VERSION::MAJOR == 3
      klass.unscoped.find(id)
    else # Rails 2
      klass.with_exclusive_scope { klass.find(id) }
    end
  rescue ActiveRecord::RecordNotFound
    raise Delayed::DeserializationError
  end
end
