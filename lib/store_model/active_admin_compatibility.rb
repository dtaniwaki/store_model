# frozen_string_literal: true

module StoreModel
  # ActiveAdmin compatibility patches
  #
  # This module contains patches that make StoreModel compatible with ActiveAdmin's
  # form builders, particularly the has_many helper which expects certain ActiveRecord-like
  # methods to be present.
  #
  # To enable these patches, set:
  #   StoreModel.config.active_admin_compatibility = true
  module ActiveAdminCompatibility
    # Reflection class for StoreModel associations.
    # This provides compatibility with form builders like ActiveAdmin's has_many
    # that expect ActiveRecord-style reflection objects.
    class Reflection
      attr_reader :name, :klass

      # @param name [Symbol] association name
      # @param klass [Class] the StoreModel class
      def initialize(name, klass)
        @name = name
        @klass = klass
      end
    end
  end
end

# Patch StoreModel::Model to add new_record? method when active_admin_compatibility is enabled
StoreModel::Model.class_eval do
  # Always returns true for StoreModel instances when ActiveAdmin compatibility is enabled.
  # This is needed for compatibility with form builders like ActiveAdmin's has_many.
  #
  # @return [Boolean]
  def new_record?
    return super if defined?(super)

    true
  end
end

# Patch StoreModel::NestedAttributes::ClassMethods to add reflection methods
StoreModel::NestedAttributes::ClassMethods.module_eval do
  # Returns reflection for the given association name.
  # This provides compatibility with form builders like ActiveAdmin's has_many.
  #
  # @param name [Symbol, String] association name
  # @return [StoreModel::ActiveAdminCompatibility::Reflection, nil]
  def reflect_on_association(name)
    return super unless StoreModel.config.active_admin_compatibility

    reflection = store_model_reflections[name.to_sym]
    return reflection if reflection

    # Try to call super if it's defined (for ActiveRecord models)
    # For pure StoreModel classes (like Supplier), there's no super method
    begin
      super
    rescue StandardError
      nil
    end
  end

  # Returns hash of registered StoreModel reflections.
  #
  # @return [Hash{Symbol => StoreModel::ActiveAdminCompatibility::Reflection}]
  def store_model_reflections
    @store_model_reflections ||= {}
  end

  # Override accepts_nested_attributes_for to register reflections
  alias_method :accepts_nested_attributes_for_without_reflection, :accepts_nested_attributes_for
  def accepts_nested_attributes_for(*attributes)
    result = accepts_nested_attributes_for_without_reflection(*attributes)

    # Register reflections for StoreModel attributes if ActiveAdmin compatibility is enabled
    if StoreModel.config.active_admin_compatibility
      options = attributes.extract_options!
      attributes.each do |attribute|
        register_store_model_reflection(attribute) if nested_attribute_type(attribute).is_a?(StoreModel::Types::Base)
      end
    end

    result
  end

  private

  def register_store_model_reflection(attribute)
    type = nested_attribute_type(attribute)
    return unless type.is_a?(StoreModel::Types::ManyBase)

    store_model_reflections[attribute.to_sym] =
      StoreModel::ActiveAdminCompatibility::Reflection.new(attribute.to_sym, type.model_klass)
  end
end
