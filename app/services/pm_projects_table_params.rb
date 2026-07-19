class PMProjectsTableParams
  VALID_SORTS = %w[id created_at total_budget].freeze

  def initialize(params)
    @params = params
  end

  def sort
    VALID_SORTS.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def page
    value = params[:page].to_i
    value.positive? ? value : 1
  end

  private

  attr_reader :params
end
