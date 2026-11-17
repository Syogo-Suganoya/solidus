# frozen_string_literal: true

class SolidusAdmin::ReimbursementTypes::Edit::Component < SolidusAdmin::Resources::Edit::Component
  # Reimbursement types use single table inheritance: without these overrides
  # the route helpers and the param key would be derived from the subclass
  # name (e.g. `reimbursement_type_store_credit`), which has no routes.
  def resource_name
    Spree::ReimbursementType.model_name.singular_route_key
  end

  def plural_resource_name
    Spree::ReimbursementType.model_name.route_key
  end
end
