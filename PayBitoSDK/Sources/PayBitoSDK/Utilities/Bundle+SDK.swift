import Foundation

private class BundleFinder {}

public extension Foundation.Bundle {
    /// A public accessor to the module bundle to avoid 'internal protection level' errors
    /// when building the library for distribution.
    static var sdkModule: Bundle = {
        let bundleName = "PayBitoSDK_PayBitoSDK"
        let candidates = [
            Bundle.main.resourceURL,
            Bundle(for: BundleFinder.self).resourceURL,
            Bundle.main.bundleURL
        ]
        
        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        
        return Bundle(for: BundleFinder.self)
    }()
}
