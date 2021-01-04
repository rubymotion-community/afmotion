require "sinatra"

set :root, File.dirname(__FILE__)
set :port, "4567"
set :bind, "0.0.0.0"
set :static, true


get "/feed" do
  content_type "text/json"
  {
    data: [
      {
        id: 1,
        text: "Trains in Motion travel on Rails",
        user: {
          id: 1,
          username: "motionuser12",
          "avatar_image.url" => "#{ request.base_url }/motionuser12_avatar.png"
        }
      },
      {
        id: 2,
        text: "Funny joke, I think",
        user: {
          id: 2,
          username: "railsuser3",
          "avatar_image.url" => "#{ request.base_url }/railsuser3_avatar.png"
        }
      },
      {
        id: 3,
        text: "The Objective, See, is to program",
        user: {
          id: 3,
          username: "swiftlytalking4",
          "avatar_image.url" => "#{ request.base_url }/swiftlytalking4_avatar.png"
        }
      }
    ]
  }.to_json
end

post "/upload" do
  pp params

  content_type "text/json"

  {result: :success}.to_json
end
