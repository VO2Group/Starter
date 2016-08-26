node {
  git([url: 'https://github.com/Lajule/Starter.git', branch: 'master'])

  sh "make"

  parallel(
    android: {
      sh "fastlane android test"
      step([$class: 'JUnitResultArchiver', testResults: '**/platforms/android/app/build/test-results/release/TEST-*.xml'])
    },
    ios: {
      sh "fastlane ios test"
      step([$class: 'JUnitResultArchiver', testResults: '**/fastlane/test_output/report.junit'])
    }
  )
}
