Pod::Spec.new do |spec|
  spec.name         = 'tumbler'
  spec.version      = '1.0.1'
  spec.license      = { :type => 'BSD' }
  spec.homepage     = 'https://www.assembla.com/code/iphone2/git-26/nodes'
  spec.authors      = { 'Sharma Elanthiraiyan' => 'sharma@inxsasia.com' }
  spec.summary      = 'JSON - Objective C model class generator.'
  spec.source       = { :git => 'git@git.assembla.com:ioslibs.tumbler.git', :tag => "#{spec.version}" }
  spec.exclude_files = 'includes/RequestNode.{h,m}'
  spec.source_files = 'includes/*'
  spec.requires_arc = true
end