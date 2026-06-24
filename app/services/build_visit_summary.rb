class BuildVisitSummary
  def initialize(params)
    @params = params
  end

  def call
    visit_summary = VisitSummary.new(@params)
    visit_summary.people = Location.includes(:active_people).find(@params[:location_id]).active_people

    visit_summary
  end
end
