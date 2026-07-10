class SubmissionPolicy
  def initialize(submission)
    @submission = submission
  end

  def allowed?
    @submission.present?
  end
end
