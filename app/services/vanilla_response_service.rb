# frozen_string_literal: true

# wrapper to auto grade questions for a gvien response
class GradeResponseService
  attr_accessor :response, :results, :auto_submit

  def initialize(response)
    @response = response
    @auto_submit = response.project.auto_submit
    @results = { total: 0, skipped: 0 }
  end

  def call
    grade_questions_for(response)
    submit_response if auto_submit

    results
  end

  def self.call(response)
    new(response).call
  end

  private

  def submit_response
    SubmitResponseService.call(response) if response.graded?
  end

  def record_result_for(response_question)
    if response_question.auto_grader_points.present?
      results[:total] += 1
    else
      results[:skipped] += 1
    end
  end

  def grade_questions_for(response)
    response.response_questions.each do |response_question|
      grade_question(response_question)
      record_result_for(response_question)
    end
  end

  def grade_question(response_question)
    if response_question.code?
      grade_code_question(response_question)
    elsif response_question.multiple_choice?
      grade_multiple_choice_question(response_question)
    end
  end

  # execute code tests to determine correctness of code question
  # code questions are auto graded as pass / fail rathe than percentages for now
  def grade_code_question(response_question)
    success, output = RunCodeService.call(
      response_question.answer_text,
      response_question.question.code_filename,
      response_question.question.code_tests
    ).values

    # nil output means it did not run we don't want to mark this wrong if it fails at the http level
    return log_code_error(response_question) if output.nil?

    persist_question(
      response_question,
      success ? potential_points_for(response_question) : 0,
      output
    )
  end

  def persist_question(response_question, points, output)
    response_question.auto_grader_points = points
    response_question.auto_grader_results = output

    if auto_submit
      response_question.points = points
      response_question.grade_results = output
    end

    response_question.save
  end

  def log_code_error(response_question)
    Rollbar.error(
      GradeResponseError.new(
        "failed to run code for: Response:#{response.id} ResponseQuestion:#{response_question.id}"
      )
    )
  end

  # calculate multiple choice percentage correct
  def grade_multiple_choice_question(response_question)
    potential_correct = response_question.answers.correct.count
    total_correct = response_question.response_question_answers.correct.count
    potential_points = potential_points_for(response_question)
    percentage_multiplier = total_correct.to_f / potential_correct

    persist_question(
      response_question,
      potential_points * percentage_multiplier,
      "#{total_correct}/#{potential_correct} correct answers chosen"
    )
  end

  def potential_points_for(response_question)
    response_question.project_assignment_question.points
  end
end

class GradeResponseError < StandardError; end
