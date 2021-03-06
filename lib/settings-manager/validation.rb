module SettingsManager
  module Validation
    extend ActiveSupport::Concern

    included do
      validates_inclusion_of :key,
        in: ->(r) { r.class.allowed_settings_keys.map { |k| k.to_s } },
        if: Proc.new { |r| r.class.allowed_settings_keys.any? },
        message: "`%{value}` is an unallowed setting"

      validates_uniqueness_of :base_obj_id,
        :scope => [:key, :base_obj_type]
    end

    def allowed_settings_keys
      self.class.allowed_settings_keys
    end

    module ClassMethods
      def allowed_settings_keys(keys = nil)
        if keys.present? && keys.kind_of?(Array)
          @allowed_settings_keys = keys
        else
          @allowed_settings_keys || []
        end
      end

      def key_allowed?(key)
        if allowed_settings_keys.any?
          allowed_settings_keys.include?(key.to_sym)
        else
          true
        end
      end

      def validates_setting(value, options = {})
        options[:if] = Proc.new { |record| value.to_s == record.key.to_s }
        validates(:value, options)
      end
    end
  end
end
