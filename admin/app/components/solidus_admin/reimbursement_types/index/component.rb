# frozen_string_literal: true

class SolidusAdmin::ReimbursementTypes::Index::Component < SolidusAdmin::RefundsAndReturns::Component
  def model_class
    Spree::ReimbursementType
  end

  def search_url
    solidus_admin.reimbursement_types_path
  end

  def search_key
    :name_cont
  end

  def edit_path(reimbursement_type)
    solidus_admin.edit_reimbursement_type_path(reimbursement_type, **search_filter_params)
  end

  def turbo_frames
    %w[
      resource_form
    ]
  end

  def columns
    [
      {
        header: :name,
        data: ->(reimbursement_type) do
          link_to reimbursement_type.name, edit_path(reimbursement_type),
            data: {turbo_frame: :resource_form},
            class: "body-link"
        end
      },
      {
        header: :active,
        data: ->(reimbursement_type) do
          reimbursement_type.active? ? component("ui/badge").yes : component("ui/badge").no
        end
      }
    ]
  end
end
