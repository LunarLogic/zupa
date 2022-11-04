Trestle.resource(:people_visit_summaries) do
  return_to on: :destroy do |instance|
    VisitSummariesAdmin.instance_path(instance.visit_summary, action: :edit) + "#!tab-people"
  end
end
