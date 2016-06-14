require 'x-editable-rails'

module Spree
  module Admin
    class DigitalsController < ResourceController
      belongs_to "spree/product", :find_by => :slug

      helper_method :xeditable?
      helper X::Editable::Rails::ViewHelpers

      def create
        invoke_callbacks(:create, :before)
        @object.attributes = permitted_resource_params
        if @object.save
          invoke_callbacks(:create, :after)
          flash[:success] = flash_message_for(@object, :successfully_created)
          respond_with(@object) do |format|
            format.html { redirect_to location_after_save }
            format.js   { render :layout => false }
          end
        else
          invoke_callbacks(:create, :fails)
          redirect_to location_after_save
        end
      end

      def notify_orders
        @product = Spree::Product.find_by(slug: params[:product_id])

        orders = Set.new

        @product.variants_including_master.each do |variant|
          if variant.digital?
            orders.merge variant.line_items.joins(:order).map(&:order)
          end
        end

        orders.each do |order|
          order.line_items.each(&:create_digital_links)

          OrderMailer.digital_downloads_ready(order).deliver
        end

        if orders.empty?
          flash[:error] = "No orders of this product were found"
        else
          flash[:success] = "Emails sent"
        end
        redirect_to :back
      end

      protected

      def xeditable?(*)
        true
      end

      def location_after_save
        spree.admin_product_digitals_path(@product)
      end

      def permitted_resource_params
        params.require(:digital).permit(permitted_digital_attributes)
      end

      def permitted_digital_attributes
        [:variant_id, :attachment]
      end

    end
  end
end
