class Post
  attr_accessor :id, :text, :user

  def initialize(attributes = {})
    self.id = attributes["id"].to_i
    self.text = attributes["text"].to_s
    self.user = User.new(attributes["user"])
  end

  def self.fetchGlobalTimelinePosts(&callback)
    AFMotion::SessionClient.shared.get("feed") do |result|
      if result.success?
        posts = []
        result.object["data"].each do |attributes|
          posts << Post.new(attributes)
        end
        callback.call(posts, nil)
      else
        callback.call([], result.error)
      end
    end
  end
end