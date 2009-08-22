# thanks to http://github.com/aussiegeek/active_record_defaults for the
# beginnings of the initialization code

module ActiveRecordEnumerable

  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.send :alias_method, :initialize_without_enumerable_defaults, :initialize
    base.send :alias_method, :initialize, :initialize_with_enumerable_defaults
  end

  module ClassMethods
    def enumerate(column, options={})
      possible_values = options.delete(:as)
      default         = options.delete(:default) || possible_values.first

      enumerable_defaults[column] = default

      validates_presence_of  column
      validates_inclusion_of column, :in => possible_values

      define_method column do
        value = self[column]
        value.nil? ? value : ActiveSupport::StringInquirer.new(value)
      end
    end

    def enumerable_defaults
      @enumerable_defaults ||= {}
    end
  end

  module InstanceMethods
    def initialize_with_enumerable_defaults(attributes=nil)
      initialize_without_enumerable_defaults(attributes)
      apply_default_attribute_values(attributes)
      yield self if block_given?
    end

    def apply_default_attribute_values(attributes)
      attribute_keys = (attributes || {}).keys.map(&:to_sym)
      self.class.enumerable_defaults.each do |column, default|
        next if attribute_keys.include?(column)
        send("#{column}=", default)
      end
    end
  end

end
