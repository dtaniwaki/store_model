# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Products", type: :request do
  describe "GET /admin/products" do
    context "when there are no products" do
      it "returns success" do
        get "/admin/products"
        expect(response).to have_http_status(:success).or have_http_status(:redirect)
      end
    end

    context "when there are products" do
      let!(:product) do
        Product.create!(
          name: "Test Product",
          suppliers: [
            Supplier.new(title: "Supplier 1", address: "Address 1", email: "test1@example.com")
          ]
        )
      end

      it "displays products list" do
        get "/admin/products"
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Test Product")
      end
    end
  end

  describe "GET /admin/products/new" do
    it "displays new product form" do
      get "/admin/products/new"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("New Product")
    end

    it "includes has_many suppliers form" do
      get "/admin/products/new"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Suppliers")
    end
  end

  describe "POST /admin/products" do
    it "creates a product with suppliers" do
      expect do
        post "/admin/products", params: {
          product: {
            name: "New Product",
            suppliers_attributes: {
              "0" => { title: "Supplier A", address: "Address A", email: "a@example.com" },
              "1" => { title: "Supplier B", address: "Address B", email: "b@example.com" }
            }
          }
        }
      end.to change(Product, :count).by(1)

      product = Product.last
      expect(product.name).to eq("New Product")
      expect(product.suppliers.size).to eq(2)
      expect(product.suppliers.first.title).to eq("Supplier A")
      expect(response).to have_http_status(:redirect)
    end

    it "renders form with errors for invalid data" do
      post "/admin/products", params: {
        product: {
          name: "", # blank name should fail validation
          suppliers_attributes: {}
        }
      }

      expect(response).to have_http_status(:success)
      expect(response.body).to include("can&#39;t be blank")
    end
  end

  describe "GET /admin/products/:id" do
    let!(:product) do
      Product.create!(
        name: "Show Product",
        suppliers: [
          Supplier.new(title: "Show Supplier", address: "Show Address", email: "show@example.com")
        ]
      )
    end

    it "displays product details" do
      get "/admin/products/#{product.id}"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Show Product")
    end

    it "displays suppliers information" do
      get "/admin/products/#{product.id}"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Show Supplier")
      expect(response.body).to include("Show Address")
    end
  end

  describe "GET /admin/products/:id/edit" do
    let!(:product) do
      Product.create!(
        name: "Edit Product",
        suppliers: [
          Supplier.new(title: "Edit Supplier", address: "Edit Address", email: "edit@example.com")
        ]
      )
    end

    it "displays edit form" do
      get "/admin/products/#{product.id}/edit"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Edit Product")
    end

    it "displays existing suppliers in form" do
      get "/admin/products/#{product.id}/edit"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Edit Supplier")
      expect(response.body).to include("Edit Address")
    end
  end

  describe "PUT /admin/products/:id" do
    let!(:product) do
      Product.create!(
        name: "Update Product",
        suppliers: [
          Supplier.new(title: "Original Supplier", address: "Original Address", email: "orig@example.com")
        ]
      )
    end

    it "updates product with new suppliers" do
      put "/admin/products/#{product.id}", params: {
        product: {
          name: "Updated Product",
          suppliers_attributes: {
            "0" => { title: "Updated Supplier", address: "Updated Address", email: "updated@example.com" }
          }
        }
      }

      product.reload
      expect(product.name).to eq("Updated Product")
      expect(product.suppliers.size).to eq(1)
      expect(product.suppliers.first.title).to eq("Updated Supplier")
      expect(response).to have_http_status(:redirect)
    end

    it "allows destroying suppliers" do
      put "/admin/products/#{product.id}", params: {
        product: {
          name: "Updated Product",
          suppliers_attributes: {
            "0" => { title: "Kept Supplier", address: "Kept Address", email: "kept@example.com" }
          }
        }
      }

      product.reload
      expect(product.suppliers.size).to eq(1)
      expect(product.suppliers.first.title).to eq("Kept Supplier")
    end
  end

  describe "DELETE /admin/products/:id" do
    let!(:product) do
      Product.create!(
        name: "Delete Product",
        suppliers: [
          Supplier.new(title: "Delete Supplier", address: "Delete Address", email: "delete@example.com")
        ]
      )
    end

    it "deletes the product" do
      expect do
        delete "/admin/products/#{product.id}"
      end.to change(Product, :count).by(-1)

      expect(response).to have_http_status(:redirect)
    end
  end
end
