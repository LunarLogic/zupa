class BuildVisitSummary
  def initialize(params)
    @params = params
  end

  def call
    visit_summary = VisitSummary.new(@params)
    visit_summary.people = Location.includes(:people).find(@params[:location_id]).people

    visit_summary
  end
end
