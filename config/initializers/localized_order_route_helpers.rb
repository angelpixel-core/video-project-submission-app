module LocalizedOrderRouteHelpers
  ORDER_ID_ROUTE_HELPERS = %i[
    order_path
    order_url
    edit_order_path
    edit_order_url
    reopen_order_path
    reopen_order_url
    cancel_order_path
    cancel_order_url
    accept_order_path
    accept_order_url
    request_refund_order_path
    request_refund_order_url
    approve_refund_request_order_path
    approve_refund_request_order_url
    reject_refund_request_order_path
    reject_refund_request_order_url
    complete_order_path
    complete_order_url
  ].freeze

  ORDER_COMMENT_ROUTE_HELPERS = %i[
    order_comments_path
    order_comments_url
  ].freeze

  (ORDER_ID_ROUTE_HELPERS + ORDER_COMMENT_ROUTE_HELPERS).each do |helper_name|
    define_method(helper_name) do |*args, **options|
      if args.first.respond_to?(:to_param)
        record = args.shift
        key = helper_name.to_s.start_with?("order_comments") ? :order_id : :id
        options = options.merge(key => record)
      end

      super(*args, **options)
    end
  end
end

ActionDispatch::Routing::UrlFor.prepend(LocalizedOrderRouteHelpers)
