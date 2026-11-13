# frozen_string_literal: true

class SolidusAdmin::Products::Show::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers
  include SolidusAdmin::Products::FormOptions

  def initialize(product:)
    @product = product
  end

  StorefrontLink = Struct.new(:name, :url, keyword_init: true)

  def form_id
    @form_id ||= "#{stimulus_id}--form-#{@product.id}"
  end

  # Links to the product page on the storefront.
  #
  # With a single store the link is relative to the current host. When there
  # are more, there is one link per store, pointing to the host the store is
  # configured with.
  #
  # @return [Array<StorefrontLink>]
  def storefront_links
    @storefront_links ||= begin
      path = SolidusAdmin::Config.storefront_product_path(@product)
      stores = Spree::Store.order(default: :desc, name: :asc).to_a

      if stores.many?
        stores.map { |store| StorefrontLink.new(name: store.name, url: "#{store_base_url(store)}#{path}") }
      else
        [StorefrontLink.new(name: stores.first&.name, url: path)]
      end
    end
  end

  private

  # Same rule as the store link in the main navigation: store urls are
  # usually a bare host, in which case https is assumed.
  def store_base_url(store)
    base_url = store.url.to_s.strip.chomp("/")
    base_url.start_with?("http") ? base_url : "https://#{base_url}"
  end
end
