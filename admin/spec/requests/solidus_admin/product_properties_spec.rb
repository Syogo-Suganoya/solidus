# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/moveable"

RSpec.describe "SolidusAdmin::ProductPropertiesController", type: :request do
  it_behaves_like "requests: moveable" do
    let(:factory) { :product_property }
  end

  describe "DELETE /destroy" do
    let(:admin_user) { create(:admin_user) }
    let!(:product_property) { create(:product_property, value: "Cotton") }

    before do
      allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
    end

    it "removes the product property and redirects to the product" do
      expect {
        delete solidus_admin.product_property_path(product_property)
      }.to change(Spree::ProductProperty, :count).by(-1)

      expect(response).to redirect_to(solidus_admin.product_path(product_property.product))
      expect(response).to have_http_status(:see_other)
    end

    it "keeps the property itself" do
      expect {
        delete solidus_admin.product_property_path(product_property)
      }.not_to change(Spree::Property, :count)
    end

    context "without permission to manage products" do
      let(:admin_user) { create(:user, spree_roles: [role]) }
      let(:role) { create(:role, name: "product_viewer") }

      before do
        Spree::Config.roles.assign_permissions "product_viewer", ["Spree::PermissionSets::ProductDisplay"]
      end

      after { Spree::Config.roles.roles.delete("product_viewer") }

      it "is forbidden" do
        expect {
          delete solidus_admin.product_property_path(product_property)
        }.not_to change(Spree::ProductProperty, :count)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "updating through the product" do
    let(:admin_user) { create(:admin_user) }
    let(:product) { create(:product) }
    let!(:material) { create(:property, name: "material", presentation: "Material") }

    before do
      allow(SolidusAdmin::Config).to receive(:enable_alpha_features?) { true }
      allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
    end

    it "adds a product property" do
      patch solidus_admin.product_path(product), params: {
        product: {product_properties_attributes: {"0" => {property_name: "material", value: "Cotton"}}}
      }

      expect(product.reload.product_properties.map { [_1.property, _1.value] }).to eq([[material, "Cotton"]])
    end

    it "ignores the empty row" do
      expect {
        patch solidus_admin.product_path(product), params: {
          product: {name: product.name, product_properties_attributes: {"0" => {property_name: "", value: ""}}}
        }
      }.not_to change(Spree::ProductProperty, :count)
    end

    it "updates the value of an existing product property" do
      product_property = create(:product_property, product:, property: material, value: "Cotton")

      patch solidus_admin.product_path(product), params: {
        product: {product_properties_attributes: {
          "0" => {id: product_property.id, property_name: "material", value: "Wool"}
        }}
      }

      expect(product_property.reload.value).to eq("Wool")
    end
  end
end
