class AppDelegate
  attr_accessor :image, :data
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    self.image = UIImage.imageNamed("test")
    self.data = UIImagePNGRepresentation(self.image)
    true
  end
end
