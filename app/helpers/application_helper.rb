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
    link_classes = [ "text-reset", "text-decoration-none", "pm-table-sort-link" ]
    link_classes << "is-active" if current_sort == sort_key

    link_options = {
      class: link_classes.join(" ")
    }
    link_options[:aria] = { current: "true" } if current_sort == sort_key

    link_to projects_path(pm_table_query_params(page: current_page, sort: next_sort, direction: next_direction)), link_options do
      safe_join([
        tag.span(label, class: "pm-table-sort-label"),
        tag.span(class: "pm-table-sort-arrows", aria: { hidden: true }) do
          safe_join([
            tag.span("↑", class: pm_table_sort_arrow_class(current_sort, sort_key, current_direction, "asc")),
            tag.span("↓", class: pm_table_sort_arrow_class(current_sort, sort_key, current_direction, "desc"))
          ])
        end
      ])
    end
  end

  def pm_table_next_sort_state(sort_key, current_sort, current_direction)
    return [ sort_key, "desc" ] if current_sort != sort_key

    case current_direction
    when "desc"
      [ sort_key, "asc" ]
    else
      [ nil, nil ]
    end
  end

  def pm_table_sort_arrow(direction)
    direction == "asc" ? "↑" : "↓"
  end

  def pm_table_sort_arrow_class(current_sort, sort_key, current_direction, direction)
    classes = [ "pm-table-sort-arrow" ]
    classes << "is-active" if current_sort == sort_key && current_direction == direction
    classes.join(" ")
  end

  def youtube_video_id(url)
    YoutubeUrlParser.video_id(url)
  end

  def youtube_embed_url(url)
    YoutubeUrlParser.embed_url(url)
  end

  def youtube_thumbnail_url(url)
    YoutubeUrlParser.thumbnail_url(url)
  end
end
