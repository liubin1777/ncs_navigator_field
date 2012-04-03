# BUG: Specifying deployment target doesn't work.
#      http://groups.google.com/group/cocoapods/browse_thread/thread/d3761ac18d9c0ec6
platform :ios, :deployment_target => "5.0"

# BUG: RestKit's podspec doesn't include CoreData/CoreData.h because it conflicts with Apple CoreData/CoreData.h
#      http://groups.google.com/group/cocoapods/browse_thread/thread/705f040f2e7aa03d
# BUG: Specifying a podspec which contains subspecs throws exception.
#      https://github.com/CocoaPods/CocoaPods/issues/141
#
# rk = "RestKit-Custom-0.9.3.podspec"
# dependency 'RestKit/Network', :podspec => rk
# dependency 'RestKit/ObjectMapping', :podspec => rk
# dependency 'RestKit/CoreData', :podspec => rk
# dependency 'RestKit/ObjectMapping/JSONKit', :podspec => rk

dependency 'SBJson', '2.2.3'
dependency 'MBProgressHUD', '0.41'
#dependency 'LibComponentLogging-Core', '1.1.6'
#dependency 'LibComponentLogging-NSLog', '1.0.4'
dependency 'RestKit/Network', '0.9.3'
dependency 'RestKit/ObjectMapping', '0.9.3'
dependency 'RestKit/ObjectMapping/CoreData', '0.9.3'
dependency 'RestKit/ObjectMapping/JSONKit', '0.9.3'

# TODO: Replace with BlocksKit?
dependency do |s|
  s.name = 'MRCEnumerable'
  s.version = '0.1'
  s.platform = :ios
  s.source = { :git => 'https://github.com/crafterm/MRCEnumerable.git', :commit => '15db6f3e48c5483d9635257511366864072ea016' }
  s.source_files = '*.{h,m}'
end

# TODO: Add to cocoapods specs repo or NUSurveyor project
dependency do |s|
  s.name = 'NUSurveyor'
  s.version = '0.0.0'
  s.platform = :ios
  s.requires_arc = true
  s.source = { :git => 'https://github.com/NUBIC/nu_surveyor.git', :commit => 'e71cc887f1' }
  s.source_files = 'NUSurveyor/NUConstants.h', 'NUSurveyor/**/*.{h,m}', 'GRMustache/*.{h,m}' #, 'JSONKit/*.{h,m}'
  s.frameworks = 'QuartzCore', 'CoreGraphics'
  s.library = 'GRMustache1-ios4'
  s.xcconfig = { 'LIBRARY_SEARCH_PATHS' => '"$(BUILT_PRODUCTS_DIR)/Pods/Libraries"' }

  def s.post_install(target_installer)
    prefix_header = config.project_pods_root + target_installer.prefix_header_filename
    prefix_header.open('a') do |file|
      file.puts(%{#ifdef __OBJC__\n#import "NUConstants.h"\n#endif})
    end

    # Add a copy build phase and make it copy the GRMustache1-ios4.a to the shared BUILT_PRODUCTS_DIR,
    # so that both the Pods project and the user's project will pick it up.    
    phase = target_installer.target.buildPhases.add(Xcodeproj::Project::PBXCopyFilesBuildPhase, 'dstPath' => 'Pods/Libraries')
    file = target_installer.project.main_group.files.new('path' => 'NUSurveyor/GRMustache/libGRMustache1-ios4.a')
    phase.files << file.buildFiles.new
    phases = target_installer.target.attributes['buildPhases']
    phases.delete(phase.uuid)
    phases.insert(1, phase.uuid)
    
    # TODO: Still need to add linker flag (-lGRMustache1-ios4) to main target
  end
end

# TODO: Add NUCas
