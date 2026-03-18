# Ounass — iOS Case Study (2024)

## Problem / Challenge

1. Implement an infinite-scroll product listing page with JSON fetched from:

   `GET https://www.ounass.ae/api/v2/women/clothing`

2. Replicate the capabilities of a product detail page using example JSON from:

   `GET https://www.ounass.ae/api/v2/{slug}.html`

3. Document the solution and explain how to run the project.

### Pagination

Pagination-related fields are under the `plp -> pagination` object.

### Documentation prompts

Helpful questions to answer in the documentation:

- Why was this design pattern selected?
- Which software design principles were followed?
- Any assumptions, comments, or notes about specific decisions?
- What would be changed with more time?
- What is needed to make the app production-ready?
- Does the project require any particular tool to run?

### Notes

- Some response fields are included only for simplicity.
- Depending on the implementation and UI, additional fields may be needed, or some may be skipped.

### Product detail context

The Ounass app on the App Store can be used as a reference for UI and functionality.

#### Product list response — important fields

- `name`
- `designerCategoryName`
- `price`
- `thumbnail`
- `noFilterUrl`

#### Product detail response — important fields

- `name`
- `designerCategoryName`
- `descriptionText`
- `price`
- `media`
- `amberPoints`

#### Additional note

- `slug` represents the slug of the product received from the product list response.
- A base URL is provided for product detail images.

## Implementation

The implementation should include:

- Product listing with infinite scroll / lazy loading and pull-to-refresh
- Required network calls
- Navigation from the product listing screen to the selected product’s detail screen
  - Every item should route to its own product detail screen
  - The product detail URL shown above is only an example
- Size and color selection on the product detail screen
- Add to Bag button state based on size and color selection
  - Actual Add to Bag functionality and network call are **not** required

## Example Scenarios

- If a color is selected on the product detail screen, size selection should be limited to sizes available for that color.
- If a product does not have more than one color option, color selection should not be activated.
- The same rule applies to size selection.
- See products in the actual app with:
  - only size options available
  - only color options available
  - neither available
- On size or color selection, the product ID, description, and images should update.

## Evaluation Criteria

- Implementation of logic and UI from a mobile development perspective
- Ability to easily add new options beyond color and size
- Code organization and design pattern that is adaptable for multi-brand development, easy to maintain, and easy to test
  - **Strictly no Apple MVC**
- Consistency in code convention and indentation
- Swift and Xcode versions and deployment target
  - Swift 5.0 or higher
  - Latest stable Xcode
  - Deployment target 13.0 or higher
- Portrait / landscape orientations and iPad compatibility
  - Different UI for landscape orientation and iPad is **not** required
- “Swifty” mindset
  - Taking advantage of Swift’s powerful features while avoiding pitfalls
- Library usage
  - No more and no less than required
