class PostTableViewCell < UITableViewCell
  attr_accessor :post

  def initWithStyle(style, reuseIdentifier:reuseIdentifier)
    super

    self.textLabel.adjustsFontSizeToFitWidth = true
    self.textLabel.textColor = UIColor.darkGrayColor
    self.detailTextLabel.font = UIFont.systemFontOfSize 12
    self.detailTextLabel.numberOfLines = 0
    self.selectionStyle = UITableViewCellSelectionStyleGray

    self
  end

  def post=(post)
    @post = post

    self.textLabel.text = self.post.user.username
    self.detailTextLabel.text = self.post.text
    self.imageView.url = {url: self.post.user.avatar_url.to_url, placeholder: UIImage.imageNamed("profile-image-placeholder")}

    self.setNeedsLayout

    @post
  end
  
  def self.heightForCellWithPost(post)
    sizeToFit = post.text.sizeWithFont(UIFont.systemFontOfSize(12), constrainedToSize: CGSizeMake(220, Float::MAX), lineBreakMode:UILineBreakModeWordWrap)
    
    return [70, sizeToFit.height + 45].max
  end

  def layoutSubviews
    super

    self.imageView.frame = CGRectMake(10, 10, 50, 50);
    self.textLabel.frame = CGRectMake(70, 10, 240, 20);

    detailTextLabelFrame = CGRectOffset(self.textLabel.frame, 0, 25);
    detailTextLabelFrame.size.height = self.class.heightForCellWithPost(self.post) - 45
    self.detailTextLabel.frame = detailTextLabelFrame
  end
end