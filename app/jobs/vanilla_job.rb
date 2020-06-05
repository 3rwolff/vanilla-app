# frozen_string_literal: true

# Automatically grade Response
class VanillaJob < ApplicationJob
  # @param [Integer] response_id id of the response to auto grade
  def perform(response_id)
    response = Response.find(response_id)

    VanillaResponseService.call(response)
  end
end
