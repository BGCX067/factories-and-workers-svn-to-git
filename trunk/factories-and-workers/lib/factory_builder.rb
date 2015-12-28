module Factory; end

class Object
  include Factory
  
  def factory(factory, default_attributes={})
    FactoryBuilder.new(factory, default_attributes)
  end
end

class FactoryBuilder
  def initialize(factory, default_attributes={})
    case factory
    when Symbol, String
      @factory = factory.to_s
    else
      raise "I don't know how to build '#{factory.inspect}'"
    end
    @default_attributes = default_attributes
    
    # make the create method
    Factory.send :define_method, :"create_#{factory.to_s}" do |attributes|
      # store the default attributes that were supplied with the factory method
      instance_variable_set("@default_attributes", @default_attributes)
      # it's impossible to set a default for an argument using define_method ???
      attributes ||= {}
      # if they stored a proc, evaluate it now that it's time to use it
      default_attributes.each do |key, value|
        attributes[key] = value.call if value.is_a?(Proc) && attributes[key].nil? 
        # don't use the default if they set their own
      end
      
      eval("#{factory.to_s.classify}.create! default_attributes.merge(attributes)")
    end#of Factory.send
    
    # make the valid attributes method
    Factory.send :define_method, :"valid_#{factory.to_s}_attributes" do
      instance_variable_set("@default_attributes", @default_attributes)
      
      # if they stored a proc, make it nil
      default_attributes.each do |key, value|
        default_attributes[key] = nil if value.is_a?(Proc)
      end
      
      return default_attributes
    end
  end
  
  def self.render_attributes_without_procs(attributes)
    
    return attributes
  end
end