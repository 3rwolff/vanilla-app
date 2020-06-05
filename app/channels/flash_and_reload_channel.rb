# frozen_string_literal: true

# Send flash messages from background jobs
class FlashAndReloadChannel < ApplicationCable::Channel
  # redis path to broadcast on
  CHANNEL_NAME = "flash_and_reload"

  # @option params [Integer] user_id current_user id who is listening to websocket flash broadcasts
  # @option params [String] type the flash message type
  # @option params [String] text the flash message text
  def self.broadcast(user_id:, type:, text:)
    ActionCable.server.broadcast(channel_for(user_id), "flash_#{type}": text)
  end
end
