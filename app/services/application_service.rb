class ApplicationService
  def self.call(*args, &block)
    new(*args, &block).call
  end

  def logger
    Rails.logger
  end
end
