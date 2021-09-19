# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end

target 'geosy' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  platform :ios, '14.5'

  # Pods for geosy
  pod 'GoogleMaps', '5.0.0'
  pod 'GooglePlaces', '5.0.0'
  pod 'Google-Maps-iOS-Utils'
  # Add the Firebase pod for Google Analytics
  pod 'Firebase/Analytics'

  # For Analytics without IDFA collection capability, use this pod instead
  # pod ‘Firebase/AnalyticsWithoutAdIdSupport’

  # Add the pods for any other Firebase products you want to use in your app
  # For example, to use Firebase Authentication and Cloud Firestore
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'Firebase/Firestore'
  pod 'GoogleSignIn'

  pod 'KeyboardObserving'

  pod 'Firebase/Storage'
  pod 'SDWebImage'
  pod 'FirebaseUI'
  pod 'FirebaseUI/Firestore'
  pod 'FirebaseUI/Storage'

  pod 'GeoFire'

  target 'geosyTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'geosyUITests' do
    # Pods for testing
  end

end
