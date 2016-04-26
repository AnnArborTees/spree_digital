Spree::Admin::VariantsController.class_eval do
  prepend_before_filter :json_update, only: :update

  protected

  def json_update
    return unless request.format.json?

    @object = Spree::Variant.find(params[:id])
    
    if @object.update_attributes(variant_params)
      respond_with(@object) do |format|
        format.json { render json: @object }
      end
    else
      respond_with(@object) do |format|
        format.json { render json: { errors: @object.errors.to_h } }
      end
    end
  end

  private

  def variant_params
    if params[:variant]
      params[:variant].permit(*permitted_variant_attributes + [:vhx_product_id])
    else
      {}
    end
  end
end