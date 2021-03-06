Pod::Spec.new do |s|
  s.name     = "Kwarter-EGOTableViewPullRefresh"
  s.version  = "0.1.0"
  s.platform = :ios
  s.license  = "MIT"
  s.summary  = "A similar control to the pull down to refresh control created by atebits in Tweetie 2."
  s.homepage = "https://github.com/kwarter/Kwarter-EGOTableViewPullRefresh"
  s.authors  = { "Devin Doty" => "devin.r.doty@gmail.com" }
  s.source   = { :git    => "https://github.com/kwarter/Kwarter-EGOTableViewPullRefresh.git", :tag => "0.1.0" }

  s.source_files = 'EGOTableViewPullRefresh/Classes/View/*.{h,m}'
  s.resources    = 'EGOTableViewPullRefresh/Resources/*.png'

  s.framework    = 'QuartzCore'
  s.dependency          'Kwarter-NUI'
end
