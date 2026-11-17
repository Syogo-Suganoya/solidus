# frozen_string_literal: true

require "spec_helper"

describe "Reimbursement Types", :js, type: :feature do
  before { sign_in create(:admin_user, email: "admin@example.com") }

  it "lists Reimbursement Types" do
    create(:reimbursement_type, name: "Default-reimbursement-type")

    visit "/admin/reimbursement_types"
    expect(page).to have_content("Default-reimbursement-type")
    expect(page).to be_axe_clean
  end

  context "when editing an existing reimbursement type" do
    let(:query) { "?page=1&q%5Bname_cont%5D=Store" }

    before do
      Spree::ReimbursementType::StoreCredit.create!(name: "Store Credit", active: false)
      visit "/admin/reimbursement_types#{query}"
      click_on "Store Credit"
      expect(page).to have_css("dialog")
      expect(page).to have_content("Edit Reimbursement Type")
    end

    it "is accessible" do
      expect(page).to be_axe_clean
    end

    it "closing the modal keeps query params" do
      within("dialog") { click_on "Cancel" }
      expect(page).not_to have_selector("dialog")
      expect(page.current_url).to include(query)
    end

    it "updates the reimbursement type, keeping its type and the query params" do
      fill_in "Name", with: "Store Credit (gift)"
      check "Active"
      click_on "Update Reimbursement Type"

      expect(page).to have_content("Reimbursement type was successfully updated.")
      expect(page.current_url).to include(query)
      expect(page).to have_content("Store Credit (gift)")
      expect(Spree::ReimbursementType.find_by(name: "Store Credit (gift)")).to have_attributes(
        active: true,
        type: "Spree::ReimbursementType::StoreCredit"
      )
    end

    it "shows validation errors" do
      fill_in "Name", with: ""
      click_on "Update Reimbursement Type"

      expect(page).to have_content("can't be blank")
      expect(page.current_url).to include(query)
    end
  end
end
