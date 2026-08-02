module Orders
  class OrderFormPresenter
    attr_reader :project, :path, :param_key, :context, :fields

    def initialize(project:, path:, context: :edit, param_key: :project, fields: Fields.new)
      @project = project
      @path = path
      @context = context.to_sym
      @param_key = param_key
      @fields = fields
    end

    def title
      case context
      when :new
        fields.new_order_title
      else
        project.draft? ? fields.resume_draft_title : fields.edit_order_title
      end
    end

    def field_name(field)
      "#{param_key}[#{field}]"
    end

    class Fields
      def new_order_title
        "Create a new order"
      end

      def edit_order_title
        "Edit order"
      end

      def resume_draft_title
        "Resume draft"
      end

      def order_details_title
        "Order details"
      end

      def name_label
        "Name"
      end

      def name_placeholder
        "Order name"
      end

      def raw_footage_url_label
        "Raw footage URL"
      end

      def raw_footage_url_placeholder
        "https://..."
      end

      def available_video_types_title
        available_offers_title
      end

      def available_offers_title
        "Available offers"
      end

      def cart_title
        "Cart"
      end

      def empty_cart_text
        "No selections yet."
      end

      def review_button_label
        "Review and pay"
      end

      def payment_modal_title
        "Payment details"
      end

      def payment_modal_description
        "This is a simulated payment step for order checkout."
      end

      def billing_email_label
        "Billing email"
      end

      def cancel_button_label
        "Cancel"
      end

      def finalize_button_label
        "Pay and create order"
      end

      def finalize_spinner_label
        "Creating order..."
      end
    end
  end
end
