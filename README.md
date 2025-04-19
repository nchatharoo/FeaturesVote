# FeaturesVote

A Swift Package for integrating feature voting capabilities into your iOS, macOS, or any Swift application.

## Overview

FeaturesVote provides a complete solution for collecting user votes on potential features for your application. It allows you to:

- Display a list of potential features to users
- Let users vote for features they want to see implemented
- Send notifications to your team when votes are cast (Discord integration included)
- Limit vote frequency to prevent abuse
- Store voting history securely in the Keychain

This package is designed to be easy to integrate, customizable, and reliable. It's built with SwiftUI for modern UI integration.

## Demo

https://github.com/user-attachments/assets/7485d3f6-2a97-4e2b-9575-cb911c6d3eaa

## Requirements

- iOS 18.0+ / macOS 13.0+
- Swift 6
- Xcode 15.0+

## Installation

### Swift Package Manager

Add FeaturesVote to your project by adding it as a dependency in your `Package.swift` file:

```swift
dependencies: [  
    .package(url: "https://github.com/nchatharoo/FeaturesVote.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. Go to File > Add Packages...
2. Enter the repository URL: `https://github.com/nchatharoo/FeaturesVote.git`
3. Select the version or branch you want to use

## Usage

### Basic Setup

1. Create a JSON file with your features:

```json
[
  {
    "id": "feature1",
    "title": "Dark Mode Support",
    "description": "Add support for dark mode throughout the application."
  },
  {
    "id": "feature2",
    "title": "Export to PDF",
    "description": "Allow exporting data to PDF format."
  }
]
```

2. Initialize the view model and view:

```swift
import FeaturesVote
import SwiftUI

struct FeatureVotingView: View {
    @State private var viewModel: FeatureVoteViewModel
    
    init() {
        // Configure with Discord webhook
        let config = VoteConfig(
            discordWebhookURL: "https://discord.com/api/webhooks/your-webhook-url",
            appIdentifier: "com.yourcompany.yourapp"
        )
        
        viewModel = FeatureVoteViewModel(config: config, jsonFilename: "features")
    }
    
    var body: some View {
        FeatureListView(viewModel: viewModel)
            .onAppear {
                viewModel.loadFeaturesFromBundle()
            }
    }
}
```

### Custom Styling

You can customize the appearance using the `FeaturesTheme` struct:

```swift
FeatureListView(viewModel: viewModel)
    .featuresTheme(
        FeaturesTheme(
            titleFontWeight: .bold,
            titleFontSize: 18,
            accentColor: .blue,
            voteButtonColor: Color(.systemGray6)
        )
    )
```

### Custom Notification Service

If you don't want to use Discord, you can create your own notification service:

```swift
class MyCustomNotificationService: VoteNotificationService {
    func sendVote(feature: Features) async throws {
        // Your implementation to notify about votes
        // For example, send to Slack, email, or your backend
    }
}

// Then initialize with your custom service
let customService = MyCustomNotificationService()
let viewModel = FeatureVoteViewModel(
    notificationService: customService,
    appIdentifier: "com.yourcompany.yourapp",
    jsonFilename: "features"
)
```

## Advanced Configuration

### Vote Limitations

You can configure voting limits to prevent abuse:

```swift
let viewModel = FeatureVoteViewModel(
    notificationService: service,
    appIdentifier: "com.yourcompany.yourapp",
    jsonFilename: "features",
    maxVotesPerDay: 5,           // Limit to 5 votes per day
    minTimeBetweenVotes: 60.0    // At least 60 seconds between votes
)
```

### Loading Features from Network

Instead of loading from a local file, you can load features from a network request:

```swift
Task {
    do {
        let (data, _) = try await URLSession.shared.data(from: featuresURL)
        viewModel.loadFeatures(from: data)
    } catch {
        // Handle error
    }
}
```

## Security

FeaturesVote uses the Keychain to securely store:
- Which features a user has voted for
- When the last vote was cast
- How many votes were cast today

This ensures vote integrity even if the app is deleted and reinstalled.

## License

FeaturesVote is available under the MIT license. See the LICENSE file for more info.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
