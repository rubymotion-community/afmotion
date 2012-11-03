class UIImageView
  def url=(url)
    case url
    when Hash
      self.setImageWithURL(url[:url].to_url, placeholderImage: url[:placeholder])
    else
      self.setImageWithURL(url.to_url)
    end
  end
end