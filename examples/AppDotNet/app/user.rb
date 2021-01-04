class User
  attr_accessor :id, :username, :avatar_url

  def initialize(attributes = {})
    self.id = attributes["id"].to_i
    self.username = attributes["username"]
    self.avatar_url = attributes["avatar_image.url"]
  end
end