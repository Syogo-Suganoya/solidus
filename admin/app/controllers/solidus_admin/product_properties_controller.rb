# frozen_string_literal: true

module SolidusAdmin
  class ProductPropertiesController < SolidusAdmin::BaseController
    include SolidusAdmin::Moveable

    def destroy
      product_property = Spree::ProductProperty.find(params[:id])
      authorize! :destroy, product_property

      product_property.destroy!

      flash[:notice] = t(".success")
      redirect_to solidus_admin.product_path(product_property.product), status: :see_other
    end
  end
end
