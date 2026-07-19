module ApplicationHelper
  def money_to_currency(cents)
    number_to_currency(cents.to_i / 100.0)
  end

  def pm_table_query_params(page:, sort: nil, direction: nil)
    { page: page }.tap do |query_params|
      query_params[:sort] = sort if sort.present?
      query_params[:direction] = direction if direction.present?
    end
  end

  def pm_table_sort_link(label, sort_key, current_sort, current_direction, current_page)
    next_sort, next_direction = pm_table_next_sort_state(sort_key, current_sort, current_direction)
    link_label = current_sort == sort_key ? "#{label} #{pm_table_sort_arrow(current_direction)}" : label
    link_classes = ["text-reset", "text-decoration-none", "pm-table-sort-link"]
    link_classes << "is-active" if current_sort == sort_key

    link_options = {
      class: link_classes.join(" ")
    }
    link_options[:aria] = { current: "true" } if current_sort == sort_key

    link_to link_label, projects_path(pm_table_query_params(page: current_page, sort: next_sort, direction: next_direction)), link_options
  end

  def pm_table_next_sort_state(sort_key, current_sort, current_direction)
    return [sort_key, "desc"] if current_sort != sort_key

    case current_direction
    when "desc"
      [sort_key, "asc"]
    else
      [nil, nil]
    end
  end

  def pm_table_sort_arrow(direction)
    direction == "asc" ? "↑" : "↓"
  end
end
