class TgBot
  def initialization(token)
    @token = token
  end

  private

    def bot
      TelegramBot.new(token: @token)
    end
end
