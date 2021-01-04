class NSString
  def to_url
    NSURL.URLWithString(self)
  end
end

class NSURL
  def to_url
    self
  end
end