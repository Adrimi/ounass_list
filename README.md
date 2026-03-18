# Ounass UIKit Case Study

UIKit-only iOS case-study app that implements:

- Product listing with infinite scroll and pull-to-refresh
- Product detail with media, pricing, amber points, and size/color selection
- MVVM + Coordinator architecture with protocol-driven services
- Unit tests for decoding, pagination, and selection behavior

## Requirements

- Xcode 26.3 or a recent stable Xcode with Swift 5+
- iOS 13.0+ deployment target
- No SwiftUI is used anywhere in the project

## Run

1. Generate the project:

```bash
xcodegen generate
```

2. Open `OunassCaseStudy.xcodeproj` in Xcode.
3. Run the `OunassCaseStudy` scheme on an iPhone or iPad simulator.

## Architecture

- `App`: app lifecycle and coordinator wiring
- `Core`: networking, image loading, decoding, shared models, selection resolver
- `Features/ProductList`: listing UI, pagination, pull-to-refresh
- `Features/ProductDetail`: detail UI, option selection, remote color switching

The app uses `MVVM + Coordinator` to avoid Apple MVC and keep navigation, networking, and view code separated. The selection engine is modeled with generic option groups and variants so additional option types can be introduced without rewriting the screen architecture.

## Design Decisions

- `UICollectionView` powers the listing with diffable data source and threshold-based pagination.
- The detail screen is a scrollable UIKit composition built from reusable views rather than SwiftUI or storyboard-driven layout.
- `URLSession` and `Decodable` are used directly to keep dependencies limited to Apple frameworks.
- Color changes trigger detail fetches for the selected style-color slug and are cached in memory so switching back is instant.
- Single-option groups are auto-resolved rather than rendered as interactive selectors.

## Assumptions

- The Ounass endpoints are publicly reachable without authentication.
- Image URLs returned with `//` are normalized with `https:`.
- Product detail media paths are resolved against the Ounass product media CDN host.

## With More Time

- Add richer HTML rendering for detail tabs and shipping content
- Add offline caching and request retry policies
- Add UI tests and snapshot tests
- Improve loading placeholders and empty-state polish
- Add analytics and structured logging

## Production Readiness

- Stronger error handling and API contract monitoring
- Better accessibility auditing and Dynamic Type tuning
- Cache invalidation strategy and disk-backed images
- Observability around pagination, detail fetch latency, and selection failures
