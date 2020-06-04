#
# Be sure to run `pod lib lint RXPiOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "RXPiOS"
  s.version          = "1.6.0"
  s.summary          = "The official Realex Payments iOS SDK for HPP and Remote API."
  s.homepage         = "https://developer.realexpayments.com"
  s.license          = 'MIT'
  s.author           = {
    "Damian Sullivan" => "damian@brightstarsoftware.com",
    "Realex Payments" => "developers@realexpayments.com"
  }

  s.source           = { :git => "https://github.com/realexpayments/rxp-ios.git", :tag => "1.5.0" }
  s.platform         = :ios, '9.0'
  s.requires_arc     = true
  s.swift_version    = '5.0'

  s.source_files = 'Pod/Classes/**/*'

end
