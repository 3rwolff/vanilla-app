class GuestsCleanupJob < ApplicationJob

  # "docker-compose up"
  # Note: you have to start/stop the redis server using "sudo service redis start"
  queue_as :default

  def perform(*args)
    puts "########## HIT THE GuestsCleanupJob ###########"
    puts *args[0]

    user = *args[0]
    lastname = *args[1]
    user.update(lastname: lastname)
    puts "###############################################"
  end
end
