# Join the RubyMotion Slack Channel #

[Here is the link.](http://motioneers.herokuapp.com/) Say hello!

# Minimum Requirements #

The minimum requirements to use this template are XCode 9.2 and
RubyMotion 5.0.

Keep in mind that if you've recently upgraded from a previous versions
of XCode or RubyMotion, you'll want to run `rake clean:all` as opposed
to just `rake clean`.

# Build #

To build using the default simulator, run: `rake` (alias `rake
simulator`).

To run on a specific type of simulator. You can run `rake simulator
device_name="SIMULATOR"`. Here is a list of simulators available:

- `rake simulator device_name='iPhone 5s'`
- `rake simulator device_name='iPhone 8 Plus'`
- `rake simulator device_name='iPhone 8 Plus'`
- `rake simulator device_name='iPhone X'`
- `rake simulator device_name='iPad Pro (9.7-inch)'`
- `rake simulator device_name='iPad Pro (10.5-inch)'`
- `rake simulator device_name='iPad Pro (12.9-inch)'`

Consider using https://github.com/KrauseFx/xcode-install (and other
parts of FastLane) to streamline management of simulators,
certificates, and pretty much everything else.

So, for example, you can run `rake simulator device_name='iPhone X'`
to see what your app would look like on iPhone X.

# Deploying to the App Store #

To deploy to the App Store, you'll want to use `rake clean
archive:distribution`. With a valid distribution certificate.

In your `Rakefile`, set the following values:

```ruby
#This is only an example, the location where you store your provisioning profiles is at your discretion.
app.codesign_certificate = "iPhone Distribution: xxxxx" #This is only an example, you certificate name may be different.

#This is only an example, the location where you store your provisioning profiles is at your discretion.
app.provisioning_profile = './profiles/distribution.mobileprovision'
```

For TestFlight builds, you'll need to include the following line
(still using the distribution certificates):

```ruby
app.entitlements['beta-reports-active'] = true
```

# Icons #

As of iOS 11, Apple requires the use of Asset Catalogs for defining
icons and launch screens. You'll find icon and launch screen templates
under `./resources/Assets.xcassets`. 

The current build has a built-in icon generate that can be triggered 
from your Rakefile. The first step is to create a PNG file (keep in 
mind that your `.png` file _cannot_ contain alpha channels) and place 
it in your `resources` directory. This file should be a minimum of 1024 
x 1024 pixels (it can be higher) and should be square (to prevent 
aspect distortion during the generation process).

To generate your icon in the Asset catalogue, add a dependency to your `Rakefile` as follows:

```ruby
task :icons => 'resources/app-icon.icon_asset'
```

For the above example, the application icon is in a file called `resources/app-icon.png`. The new icons are then generated with the following command:

```sh
bundle exec rake icons
```
Once complete the new set of icon assets (and the `Contents.json` file)
are generated. Additionally the file `resources/app-icon.icon_asset` will be 
created (and should be added to git) to track when the generated icons require
a rebuild (the above command can be run multiple time and will only regenerated
when the base `.png` is newer than the icon assets).

To make the icon generate part of your regular build process, add then following
dependency (replacing the previous dependency):

```ruby
task 'build:icons' => 'resources/app-icon.icon_asset'
```

Now, the icon assets will be regenerated (if the `resources/app-icon.png` file is newer than the assets) whenever you run any `bundle exec rake` command.

For more information about Asset Catalogs, refer to this link: https://developer.apple.com/library/content/documentation/Xcode/Reference/xcode_ref-Asset_Catalog_Format/

*Note:* For existing projects that do not have the Assets.xcassets directories from the new 
RubyMotion templates can simply add the `task 'build:icons' ...` dependency from above and 
all of the necessary files will be generated. 