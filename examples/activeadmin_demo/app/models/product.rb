class Product < ApplicationRecord
  include StoreModel::NestedAttributes

  attribute :suppliers, Supplier.to_array_type, default: -> { [] }
  accepts_nested_attributes_for :suppliers, allow_destroy: true

  validates :name, presence: true

  # Ransack configuration for ActiveAdmin search
  def self.ransackable_attributes(auth_object = nil)
    ["name", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
