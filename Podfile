# Override Firebase SDK Version
$FirebaseSDKVersion = '6.33.0'
# Uncomment this line to define a global platform for your project
platform :ios, '11.0'
use_frameworks!
# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def parse_KV_file(file, separator='=')
  file_abs_path = File.expand_path(file)
  if !File.exists? file_abs_path
    return [];
  end
  pods_ary = []
  skip_line_start_symbols = ["#", "/"]
  File.foreach(file_abs_path) { |line|
      next if skip_line_start_symbols.any? { |symbol| line =~ /^\s*#{symbol}/ }
      plugin = line.split(pattern=separator)
      if plugin.length == 2
        podname = plugin[0].strip()
        path = plugin[1].strip()
        podpath = File.expand_path("#{path}", file_abs_path)
        pods_ary.push({:name => podname, :path => podpath});
      else
        puts "Invalid plugin specification: #{line}"
      end
  }
  return pods_ary
end

target 'Runner' do
  # Prepare symlinks folder. We use symlinks to avoid having Podfile.lock
  # referring to absolute paths on developers' machines.
  pod 'FirebaseFirestore', :git => 'https://github.com/invertase/firestore-ios-sdk-frameworks.git', :tag => $FirebaseSDKVersion
  system('rm -rf .symlinks')
  system('mkdir -p .symlinks/plugins')

  # Flutter Pods
  generated_xcode_build_settings = parse_KV_file('./Flutter/Generated.xcconfig')
  if generated_xcode_build_settings.empty?
    puts "Generated.xcconfig must exist. If you're running pod install manually, make sure flutter packages get is executed first."
  end
  generated_xcode_build_settings.map { |p|
    if p[:name] == 'FLUTTER_FRAMEWORK_DIR'
      symlink = File.join('.symlinks', 'flutter')
      File.symlink(File.dirname(p[:path]), symlink)
      pod 'Flutter', :path => File.join(symlink, File.basename(p[:path]))
    end
  }

  # Plugin Pods
  plugin_pods = parse_KV_file('../.flutter-plugins')
  plugin_pods.map { |p|
    symlink = File.join('.symlinks', 'plugins', p[:name])
    File.symlink(p[:path], symlink)
    pod p[:name], :path => File.join(symlink, 'ios')
  }
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
              '$(inherited)',
              ## dart: PermissionGroup.calendar
              'PERMISSION_EVENTS=0',

              ## dart: PermissionGroup.reminders
              'PERMISSION_REMINDERS=0',

              ## dart: PermissionGroup.contacts
              # 'PERMISSION_CONTACTS=0',

              ## dart: PermissionGroup.camera
              # 'PERMISSION_CAMERA=0',

              ## dart: PermissionGroup.microphone
              'PERMISSION_MICROPHONE=0',

              ## dart: PermissionGroup.speech
              'PERMISSION_SPEECH_RECOGNIZER=0',

              ## dart: PermissionGroup.photos
              # 'PERMISSION_PHOTOS=0',

              ## dart: [PermissionGroup.location, PermissionGroup.locationAlways, PermissionGroup.locationWhenInUse]
              # 'PERMISSION_LOCATION=0',

              ## dart: PermissionGroup.notification
              # 'PERMISSION_NOTIFICATIONS=0',

              ## dart: PermissionGroup.mediaLibrary
              # 'PERMISSION_MEDIA_LIBRARY=0',

              ## dart: PermissionGroup.sensors
              # 'PERMISSION_SENSORS=0'
      ]
    end
  end
end
