class PagesController < ApplicationController
  def index
    puts "HIT THE PAGES CONTROLLER"

    User.first.update(firstname: "Bob", lastname: "Parker")
    puts "@@@@@@@@@ User's Name: #{User.first.firstname} #{User.first.lastname} @@@@@@@@"

    # Enqueue a job to be performed as soon as the queuing system is free.
    GuestsCleanupJob.perform_later(user: User.first, lastname: "Marco")

    puts "@@@@@@@@@ User's Name: #{User.first.firstname} #{User.first.lastname} @@@@@@@@"
  end
end
