module ApplicationHelper
  def money_to_currency(cents)
    number_to_currency(cents.to_i / 100.0)
  end

  def pm_table_sort_link(label, sort_key, current_sort)
    arrow = case sort_key
            when "id" then "↑"
            else "↓"
            end

    link_label = current_sort == sort_key ? "#{label} #{arrow}" : label
    link_to link_label, projects_path(sort: sort_key, page: 1), class: "text-reset text-decoration-none"
  end
end
