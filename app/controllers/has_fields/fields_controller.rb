module HasFields
  class FieldsController < ApplicationController
    before_filter :authenticate_user!
    before_filter :load_fieldable, :except => [:manage]
    before_filter :load_resource
    before_filter :load_fields, :only => [:index, :edit, :manage]
    
    layout "application"

    def index
      respond_to do |format|
        format.html { render "/has_fields/fields/_index", :layout => true }
        format.js { render "/has_fields/fields/_index" }
      end
    end

    def edit
      respond_to do |format|
        format.html { render "/has_fields/fields/_edit", :layout => true }
        format.js { render "/has_fields/fields/_edit" }
      end
    end

    def update
      if @fieldable.update_attributes(params[:fieldable])
        respond_to do |format|
          format.html { redirect_to "/#{@fieldable.class.table_name}/#{@fieldable.id}/overview" }
          format.js { render "/has_fields/fields/_index", :locals => {:edit => true} }
        end
      else
        respond_to do |format|
          load_fields
          format.html { render "/has_fields/fields/_edit" }
          format.js { render "/has_fields/fields/_edit", :locals => {:edit => true} }
        end
      end
    end
    
    def manage
      respond_to do |format|
        format.html { render "/has_fields/fields/_manage", :layout => true }
        format.js { render "/has_fields/fields/_manage" }
      end
    end

    def recently_vieweds
      true
    end

    def tab
      "fields"
    end

    protected
    def load_fieldable
      load(base_path)
      @fieldable = instance_variable_get("@#{params[:resource].singularize}")
    end

    def load_fields
      @fields = {}
      HasFields.config[@resource.classify][:scopes].each do |scope|
        @fields[scope] = @resource.classify.constantize.fields(scope == :user ? current_user : current_user.send(scope))
      end
    end

    def load_resource
      @resource = params[:resource]
    end
    
    # TODO: remove me, added this because it fails in prod "undefined local variable or method `controller' for #<HasFields::FieldsController:0x0000000814fef8>
    def base_path
      self.base_path ? self.base_path : self.controller_name
    end
  end
end

