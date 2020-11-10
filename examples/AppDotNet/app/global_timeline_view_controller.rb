class GlobalTimelineViewController < UITableViewController
  attr_accessor :posts
  attr_accessor :activityIndicatorView

  def reload
    self.activityIndicatorView.startAnimating
    self.navigationItem.rightBarButtonItem.enabled = true

    Post.fetchGlobalTimelinePosts do |posts, error|
      if (error)
        UIAlertView.alloc.initWithTitle("Error",
          message:error.localizedDescription,
          delegate:nil,
          cancelButtonTitle:nil,
          otherButtonTitles:"OK", nil).show
      else
        self.posts = posts
      end

      self.activityIndicatorView.stopAnimating
      self.navigationItem.rightBarButtonItem.enabled = true
    end
  end

  def posts
    @posts ||= []
  end

  def posts=(posts)
    @posts = posts
    self.tableView.reloadData
    @posts
  end

  def loadView
    super

    self.activityIndicatorView = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleWhite)
    self.activityIndicatorView.hidesWhenStopped = true
  end

  def viewDidLoad
    super

    self.title = "Feed Example"

    self.navigationItem.leftBarButtonItem = UIBarButtonItem.alloc.initWithCustomView(self.activityIndicatorView)
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemRefresh, target:self, action: 'reload')

    self.tableView.rowHeight = 70

    self.reload
  end

  def viewDidUnload
    self.activityIndicatorView = nil

    super
  end

  def tableView(tableView, numberOfRowsInSection:section)
    self.posts.count
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    @@identifier ||= "Cell"

    cell = tableView.dequeueReusableCellWithIdentifier(@@identifier) || begin
      PostTableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:@@identifier)
    end

    cell.post = self.posts[indexPath.row]
  
    cell
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    PostTableViewCell.heightForCellWithPost(self.posts[indexPath.row])
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
  end
end