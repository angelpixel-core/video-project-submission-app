class PMProjectsTableParams
  VALID_SORTS = %w[id created_at total_budget].freeze
  VALID_DIRECTIONS = %w[asc desc].freeze

  def initialize(params)
    @params = params
  end

  def sort
    VALID_SORTS.include?(params[:sort]) ? params[:sort] : nil
  end

  def direction
    VALID_DIRECTIONS.include?(params[:direction]) ? params[:direction] : nil
  end

  def page
    value = params[:page].to_i
    value.positive? ? value : 1
  end

  private

  attr_reader :params
end
