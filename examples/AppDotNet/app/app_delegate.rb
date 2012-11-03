class AppDelegate
  attr_accessor :navigationController, :window
  def application(application, didFinishLaunchingWithOptions:launchOptions)

    AFMotion::Client.build_shared("https://alpha-api.app.net/") do
      header "Accept", "application/json"

      operation :json
    end

    url_cache = NSURLCache.alloc.initWithMemoryCapacity(4 * 1024 * 1024, diskCapacity:20 * 1024 * 1024,diskPath:nil)
    NSURLCache.setSharedURLCache(url_cache)

    AFNetworkActivityIndicatorManager.sharedManager.enabled = true

    viewController = GlobalTimelineViewController.alloc.initWithStyle(UITableViewStylePlain)

    self.navigationController = UINavigationController.alloc.initWithRootViewController(viewController)
    self.navigationController.navigationBar.tintColor = UIColor.darkGrayColor

    self.window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    self.window.backgroundColor = UIColor.whiteColor
    self.window.rootViewController = self.navigationController
    self.window.makeKeyAndVisible

    true
  end
end
