class UploadViewController < UIViewController

  def viewDidLoad
    @upload_button = UIButton.buttonWithType(UIButtonTypeCustom)
    @upload_button.setTitle("Upload Avatar", forState: UIControlStateNormal)
    @upload_button.setTitleColor(UIColor.blueColor, forState: UIControlStateNormal)
    @upload_button.backgroundColor = UIColor.lightGrayColor
    @upload_button.titleEdgeInsets = UIEdgeInsetsMake(8,8,8,8)
    @upload_button.layer.cornerRadius = 6
    @upload_button.sizeToFit
    @upload_button.frame.size.width = 200


    @upload_button.addTarget(self, action: "upload_avatar", forControlEvents: UIControlEventTouchUpInside)

    avatar_image = UIImageView.alloc.initWithImage(UIImage.imageNamed("sample_upload.png"))
    avatar_image.contentMode = UIViewContentModeScaleAspectFit

    @progress_bar = UIProgressView.alloc.init

    @stack = UIStackView.alloc.init
    @stack.axis = UILayoutConstraintAxisVertical
    @stack.alignment = UIStackViewAlignmentFill
    @stack.distribution = UIStackViewDistributionEqualSpacing
    @stack.spacing = 16.0
    @stack.layoutMarginsRelativeArrangement = true
    @stack.layoutMargins = UIEdgeInsetsMake(16,16,16,16)



    @stack.addArrangedSubview(avatar_image)
    @stack.addArrangedSubview(@progress_bar)
    @stack.addArrangedSubview(@upload_button)

    view.addSubview(@stack)
  end

  def viewWillAppear(a)
    @progress_bar.frame.size.width = 200
    @stack.frame = CGRectMake(0,40,view.bounds.size.width, view.bounds.size.width - 100)
  end


  def upload_avatar

    @upload_button.enabled = false

    client = AFMotion::SessionClient.build("http://localhost:4567")
    data = UIImagePNGRepresentation(UIImage.imageNamed("sample_upload.png"))

    progress_block = proc do |progress|
      Dispatch::Queue.main.async do
        @progress_bar.setProgress(progress.fractionCompleted, animated: true)
      end
    end

    client.multipart_post("upload", params: { avatar_upload: "other stuff" }, progress_block: progress_block) do |result, form_data|
      if form_data
        form_data.appendPartWithFileData(data, name: "avatar", fileName:"sample_upload.png", mimeType: "image/png")
      elsif result
        @upload_button.enabled = true

        if result.error
          alert("Error", result.error.localizedDescription)
        else
          alert("Complete!", result.body.to_s)
        end
      end
    end
  end

  def alert(title, message)
    UIAlertView.alloc.initWithTitle(title,
      message:message,
      delegate:nil,
      cancelButtonTitle:nil,
      otherButtonTitles:"OK", nil).show
  end
end
