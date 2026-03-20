# Ounass iOS Case Study

This repository implements the 2024 Ounass iOS case-study brief as a UIKit application for iPhone and iPad. The delivered scope covers a paginated product listing sourced from `GET /women/clothing`, navigation into product detail screens fetched by slug from `GET /{slug}.html`, pull-to-refresh, infinite scrolling, and variant-aware product detail rendering where media, description, price, and Amber points update alongside the current selection state.

The project is documented for reviewers rather than end users. The goal of the implementation is to satisfy the brief with maintainable, testable UIKit code while avoiding Apple MVC and leaving clear extension points for future product options beyond color and size.

## What Was Built

- Product listing screen with remote data loading, pull-to-refresh, and infinite scroll based on the API pagination payload.
- Product detail screen reached from each product card by its own slug, not a hard-coded sample URL.
- Variant selection flow for color and size, including disabled incompatible values and Add to Bag enablement only when required selections resolve to an available variant.
- Variant-driven updates for detail content, including media, description, price, and Amber points.
- Support for products with multiple options, a single option, or no options at all.
- Portrait and landscape support on iPhone, plus iPad compatibility as configured in the project settings.

## Architecture

The app uses a UIKit composition rooted in `RootCoordinator`, small repositories behind protocols, and generic resource-loading adapters and presenters instead of placing networking, navigation, and presentation logic directly inside view controllers.

- `RootCoordinator` owns app startup and navigation flow between the product list and product detail screens.
- `ProductListRepositoryProtocol` and `ProductDetailRepositoryProtocol` isolate remote data access from UI code.
- `LoadResourcePresentationAdapter` manages async loading lifecycles and forwards results into `LoadResourcePresenter`.
- `LoadResourcePresenter` maps loaded resources into display updates while coordinating loading and error states.
- `SelectionStateResolver` is the option-combination engine that determines selected values, compatible choices, displayed variants, and Add to Bag availability.
- Product options are modeled generically with `ProductOptionGroup`, `ProductOptionValue`, and `ProductVariant`, so the selection pipeline is not hard-wired to only color and size.

This structure avoids Apple MVC by keeping controllers focused on view composition and user interaction, while data fetching, navigation, mapping, and selection logic remain isolated and testable.

## Feature Coverage

- The list screen requests the first page from `/women/clothing`, appends additional pages using the `nextPage` path from the pagination payload, and supports pull-to-refresh to reload from the first page.
- Product selection from the list routes to a detail screen for that product's slug.
- If a detail response exposes more than one color, the UI renders a swatch selector. If there is only one color, it is preselected and the selector is not shown.
- If a detail response exposes more than one size, the UI renders a size selector. If there is only one size, the selector is omitted, and an available single size is preselected.
- If a product has no selectable options, the resolver treats the only variant as the displayed variant and enables Add to Bag immediately.
- When color and size both exist, selecting a color constrains the set of enabled sizes to variants that remain available for that color.
- When a color maps to a different remote slug, the screen fetches that alternate detail payload and refreshes the product media, description, price, and Amber points from the newly selected variant context.
- Previously loaded color variants are cached in memory by style-color ID so returning to a prior color can reuse the loaded detail model.
- The Add to Bag button reflects selection state only. The brief explicitly excludes the real Add to Bag request, and this project keeps that action out of scope.

## Design Decisions

The case study asked for code organization that is adaptable, maintainable, testable, and explicitly not Apple MVC. The implementation answers that by separating concerns along the edges that change most often in commerce apps: navigation, remote loading, response decoding, presentation mapping, and option-resolution rules.

- Dependency inversion: view composition depends on repository protocols rather than concrete fetch implementations.
- Composition over inheritance: screens are assembled from adapters, presenters, reusable cell controllers, and focused UI views instead of deep controller hierarchies.
- Testable presentation logic: pagination behavior, decoding, image-loading interactions, and option resolution are exercised without needing end-to-end UI automation for every scenario.
- Extensibility: option handling is generic enough to support additional product dimensions by introducing new option groups and variants rather than rewriting the screen architecture around specific fields.

## UI / Design Direction

The visual direction follows the "Digital Atelier" notes in `stitch/DESIGN.md` and is implemented in UIKit rather than through a separate design-system package.

- A warm neutral background and muted surface hierarchy replace stark white, using the palette defined in `UIColor+hex.swift`.
- Typography uses serif display styling for editorial emphasis and sans-serif text for functional content through `UIFont+Atelier.swift`.
- The detail screen uses generous vertical spacing, full-width imagery, and hard-edged controls to keep the interface quiet and product-led.
- The navigation bar uses a translucent blurred appearance, echoing the design brief's emphasis on lightweight chrome over boxed-in UI.

## Assumptions and Notes

- The public Ounass endpoints used by the brief are assumed to be reachable without authentication.
- Protocol-relative image URLs such as `//...` are normalized to `https://...`.
- Product media paths from detail payloads are resolved against the Ounass catalog media CDN.
- The current remote client uses a `WKWebView`-backed fetcher (`WKWebFetcher`) rather than `URLSession`, and JSON is extracted from the page body text before decoding.
- The checked-in `.xcodeproj` is the default entry point for running the app. `project.yml` exists so the project can be regenerated when needed, but regeneration is optional for normal review.

## Run and Test

### Requirements

- Recent stable Xcode
- Swift 5.9 as defined in `project.yml`
- iOS 13.0 deployment target or newer simulator runtime
- `xcodegen` only if you want to regenerate the checked-in Xcode project from `project.yml`

### Run

1. Open `OunassCaseStudy.xcodeproj` in Xcode.
2. Select the `OunassCaseStudy` scheme.
3. Run the app on an iPhone or iPad simulator.

If you need to regenerate the project file first:

```bash
xcodegen generate
```

### Test Coverage

The repository includes Swift Testing-based coverage for:

- response decoding and domain mapping
- product list pagination and refresh behavior
- product list image-loading and selection interactions
- selection-state rules for size-only, color-only, mixed-option, and no-option products
- live API integration checks against the public Ounass endpoints

## With More Time

- Add UI tests and snapshot coverage for the main list and detail flows.
- Improve richer editorial content rendering for long-form product sections such as composition, shipping, and advisory content.
- Add stronger offline and retry behavior around image and detail loading.
- Expand in-memory caching into a clearer caching policy for lists, images, and previously visited detail payloads.
- Refine loading states and failure recovery so the experience feels closer to a production luxury-commerce app.

## Production Readiness

- Replace or harden the current web-view-backed fetch approach with a production-grade networking strategy, while preserving the existing repository boundaries.
- Add API contract monitoring and more defensive handling for partial or shifting payload shapes.
- Improve accessibility coverage, including Dynamic Type behavior, VoiceOver review, and touch target validation.
- Add structured analytics and operational logging around pagination, detail fetches, remote variant switches, and selection failures.
- Define a broader quality bar around performance, offline behavior, caching invalidation, and automated UI regression testing.
