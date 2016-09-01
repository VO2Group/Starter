node {
  git([url: 'https://github.com/Lajule/Starter.git', branch: 'master'])

  stage 'Build and copy HTML5 application to platforms directories'
  sh 'make'

  parallel(
    android: {
      stage 'Runs all the Android tests'
      sh 'fastlane android test'
      step([$class: 'JUnitResultArchiver', testResults: '**/platforms/android/app/build/test-results/release/TEST-*.xml'])

      stage 'Compile the Android application'
      sh 'fastlane android compile'

      stage 'Submit the Android application'
      sh 'fastlane android store'

      stage 'Archive Android application'
      archive '**/Starter.apk'
    },
    ios: {
      stage 'Runs all the iOS tests'
      sh 'fastlane ios test'
      step([$class: 'JUnitResultArchiver', testResults: '**/fastlane/test_output/report.junit'])

      stage 'Compile the iOS application'
      sh 'fastlane ios compile'

      stage 'Submit the iOS application'
      sh 'fastlane ios store'

      stage 'Archive iOS application'
      archive '**/Starter.ipa'
    }
  )
}
