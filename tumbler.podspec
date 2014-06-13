Pod::Spec.new do |spec|
  spec.name         = 'tumbler'
  spec.version      = '0.0.2'
  spec.license      = { :type => 'BSD' }
  spec.homepage     = 'https://github.com/tonymillion/Reachability'
  spec.authors      = { 'Sharma Elanthiraiyan' => 'sharma@inxsasia.com' }
  spec.summary      = 'ARC and GCD Compatible Reachability Class for iOS and OS X.'
  spec.source       = { :git => 'git@git.assembla.com:iphone2.classGenerator.git', :tag => "#{spec.version}" }
  spec.exclude_files = 'includes/RequestNode.{h,m}'
  spec.source_files = 'includes/*'
  spec.requires_arc = true
end