# frozen_string_literal: true

class Supplier
  include StoreModel::Model

  attribute :title, :string
  attribute :address, :string
  attribute :email, :string
end
