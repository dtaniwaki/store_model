# ActiveAdmin + StoreModel Demo Application

This is a demonstration Rails application showing how to use StoreModel with ActiveAdmin's `has_many` form builder.

## Overview

This demo shows:
- How to configure StoreModel for ActiveAdmin compatibility
- Using `has_many` form builder with StoreModel arrays
- Creating, updating, and destroying nested StoreModel attributes
- Displaying StoreModel data in ActiveAdmin show pages

## Models

### Product
- `name`: string
- `suppliers`: JSON array of Supplier objects

### Supplier (StoreModel)
- `title`: Company name
- `address`: Company address
- `email`: Contact email

## Setup

```bash
# Install dependencies
bundle install

# Setup database
rails db:migrate

# Start the server
rails server
```

## Usage

1. Visit http://localhost:3000 (redirects to /admin)
2. Click on "Products" in the navigation
3. Click "New Product" to create a product with suppliers
4. Use the "Add New Supplier" button to add multiple suppliers
5. Use the "Remove" checkbox to delete suppliers

## How It Works

### Configuration

The StoreModel ActiveAdmin compatibility is enabled in `config/initializers/store_model.rb`:

```ruby
StoreModel.config.active_admin_compatibility = true
```

### Product Model

```ruby
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
```

### ActiveAdmin Resource

```ruby
ActiveAdmin.register Product do
  permit_params :name, suppliers_attributes: [:id, :title, :address, :email, :_destroy]

  form do |f|
    f.inputs "Product Details" do
      f.input :name
    end

    f.inputs "Suppliers" do
      f.has_many :suppliers, allow_destroy: true, new_record: true do |s|
        s.input :title, label: "Company Name"
        s.input :address
        s.input :email
      end
    end

    f.actions
  end
end
```

## Key Features Demonstrated

1. **ActiveAdmin Compatibility**: StoreModel provides the necessary methods (`new_record?`, `reflect_on_association`) for ActiveAdmin's form builders

2. **Nested Attributes**: Full support for creating, updating, and destroying nested StoreModel objects

3. **Dynamic Forms**: Add/remove suppliers dynamically in the form

4. **Data Persistence**: Suppliers are stored as JSON in the database

## Learn More

- [StoreModel Documentation](https://github.com/DmitryTsepelev/store_model)
- [ActiveAdmin Documentation](https://activeadmin.info/)
- [StoreModel ActiveAdmin Integration Guide](../../ACTIVEADMIN_INTEGRATION.md)
