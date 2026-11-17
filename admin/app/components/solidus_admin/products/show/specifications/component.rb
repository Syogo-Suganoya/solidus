# frozen_string_literal: true

class SolidusAdmin::Products::Show::Specifications::Component < SolidusAdmin::BaseComponent
  def initialize(product:, form:)
    @product = product
    @form = form
  end

  private

  def product_properties
    @product_properties ||= @product.product_properties.includes(:property).select(&:persisted?)
  end

  # Product properties are saved together with the product, through its
  # nested attributes.
  def field_name(index, attribute)
    "#{@form.object_name}[product_properties_attributes][#{index}][#{attribute}]"
  end

  def new_index
    product_properties.size
  end

  def property_options
    Spree::Property.sorted.pluck(:presentation, :name).map do |presentation, name|
      [(presentation == name) ? name : "#{presentation} (#{name})", name]
    end
  end
end
