class PMTableQuery
  SORTS = {
    "id" => "projects.id",
    "created_at" => "projects.created_at",
    "total_budget" => "total_budget_cents"
  }.freeze

  def initialize(sort: "created_at", page: 1, per_page: 10)
    @sort = sort
    @page = page.to_i
    @per_page = per_page.to_i
  end

  def call
    relation
      .order(Arel.sql("#{order_column} #{order_direction}"))
      .limit(per_page)
      .offset((page - 1) * per_page)
  end

  def total_pages
    (total_count.to_f / per_page).ceil
  end

  def total_count
    Project.where.not(status: :draft).count
  end

  private

  attr_reader :sort, :page, :per_page

  def relation
    Project.for_pm_table.where.not(status: :draft).includes(:client)
  end

  def order_column
    SORTS.fetch(sort, SORTS["created_at"])
  end

  def order_direction
    sort == "id" ? "ASC" : "DESC"
  end
end
