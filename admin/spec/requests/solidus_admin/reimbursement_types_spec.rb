# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/crud_resource_requests"

RSpec.describe "SolidusAdmin::ReimbursementTypesController", type: :request do
  include_examples "CRUD resource requests", "reimbursement_type",
    except: [:new, :create, :destroy_single, :destroy_bulk] do
    let(:resource_class) { Spree::ReimbursementType }
    let(:valid_attributes) { {name: "Gift card", active: false} }
    let(:invalid_attributes) { {name: "", active: false} }
  end

  context "with a reimbursement type subclass" do
    let(:admin_user) { create(:admin_user) }
    let(:reimbursement_type) { Spree::ReimbursementType::StoreCredit.create!(name: "Store Credit") }

    before do
      allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
    end

    it "renders the edit form" do
      get solidus_admin.edit_reimbursement_type_path(reimbursement_type)

      expect(response).to have_http_status(:ok)
    end

    it "does not allow changing the type" do
      patch solidus_admin.reimbursement_type_path(reimbursement_type),
        params: {reimbursement_type: {name: "Renamed", type: "Spree::ReimbursementType::Credit"}}

      expect(reimbursement_type.reload).to have_attributes(
        name: "Renamed",
        type: "Spree::ReimbursementType::StoreCredit"
      )
    end
  end
end
