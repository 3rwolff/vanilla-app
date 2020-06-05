class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
  def flash_and_reload_for(user_id, type, text)
    FlashAndReloadChannel.broadcast(user_id: user_id, type: type, text: text)
  end
end
