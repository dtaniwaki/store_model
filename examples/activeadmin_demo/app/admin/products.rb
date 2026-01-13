ActiveAdmin.register Product do
  permit_params :name, suppliers_attributes: [:id, :title, :address, :email, :_destroy]

  # Configure filters to exclude suppliers (JSON attribute)
  filter :name
  filter :created_at
  filter :updated_at

  # Configure index columns
  index do
    selectable_column
    id_column
    column :name
    column :created_at
    column :updated_at
    actions
  end

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

  show do
    attributes_table do
      row :name
      row :created_at
      row :updated_at
    end

    panel "Suppliers" do
      table_for product.suppliers do
        column :title
        column :address
        column :email
      end
    end
  end
end
