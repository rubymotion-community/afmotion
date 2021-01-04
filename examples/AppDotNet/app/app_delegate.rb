class AppDelegate
  attr_accessor :navigationController, :window
  def application(application, didFinishLaunchingWithOptions:launchOptions)

    AFMotion::SessionClient.build_shared("http://localhost:4567") do
      session_configuration :default
      header "Accept", "application/json"

      request_serializer :json
    end

    url_cache = NSURLCache.alloc.initWithMemoryCapacity(4 * 1024 * 1024, diskCapacity:20 * 1024 * 1024,diskPath:nil)
    NSURLCache.setSharedURLCache(url_cache)

    AFNetworkActivityIndicatorManager.sharedManager.enabled = true

    feedController = GlobalTimelineViewController.alloc.initWithStyle(UITableViewStylePlain)
    uploadController = UploadViewController.alloc.init
    uploadController.title = "Upload Example"

    feedController.tabBarItem.image = UIImage.imageNamed("feed")
    uploadController.tabBarItem.image = UIImage.imageNamed("upload")

    self.navigationController = UITabBarController.alloc.init
    self.navigationController.tabBar.tintColor = UIColor.darkGrayColor
    self.navigationController.setViewControllers([feedController, uploadController], animated: false)

    self.window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    self.window.backgroundColor = UIColor.whiteColor
    self.window.rootViewController = self.navigationController
    self.window.makeKeyAndVisible

    true
  end
end
