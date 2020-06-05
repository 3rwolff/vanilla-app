class PagesController < ApplicationController
  def index
    puts "hit the pages controller"

    # Enqueue a job to be performed as soon as the queuing system is
    # free.
    GuestsCleanupJob.perform_later("Input for Job")
  end
end
