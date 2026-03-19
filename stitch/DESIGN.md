# Design System: The Digital Atelier

## 1. Overview & Creative North Star
**Creative North Star: "The Infinite Gallery"**

This design system is not a utility; it is a curation. We are moving away from the "app-as-a-tool" mentality and toward "app-as-an-experience." To achieve a high-end, luxury e-commerce aesthetic for iOS, we embrace **The Infinite Gallery**—a philosophy where the interface recedes to allow high-fashion photography to command the user’s full attention.

We break the standard "mobile template" through **Architectural Asymmetry**. Instead of centered, boxed-in content, we use staggered image grids and expansive white space to create a sense of rhythm and pace. This system values the "silent" areas of the screen as much as the interactive ones. The result is a digital environment that feels like a physical flagship boutique: quiet, expensive, and intentional.

---

## 2. Colors
Our palette is rooted in a "Warm Minimalist" spectrum. It avoids the clinical coldness of pure white (#FFFFFF) in favor of a sophisticated, bone-toned surface.

### Tonal Strategy
*   **Primary (`#5f5e5e`)**: Used for core structural elements and high-contrast text. It is a "Soft Black" that feels more premium than true black.
*   **Secondary (`#785a1a`)**: Our "Burnished Gold." Use this sparingly for moments of prestige—call-to-actions, limited edition tags, or signature accents.
*   **Surface Hierarchy (`#fcf9f8` to `#e4e2e2`)**: The foundation of the "Atelier" look. We use these tones to create depth without borders.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders to section content. Traditional dividers are hallmarks of cheap UI. 
*   **Sectioning:** Define boundaries solely through background color shifts. For example, a `surface-container-low` (`#f6f3f2`) section should sit on a `background` (`#fcf9f8`) to denote a new category.
*   **Signature Textures:** For primary CTAs, apply a subtle linear gradient transitioning from `primary` (`#5f5e5e`) to `primary-dim` (`#535252`) at a 15-degree angle. This adds a "weighted" feel that flat color cannot replicate.

---

## 3. Typography
The system relies on the tension between the classic elegance of **Noto Serif** and the modern precision of **Inter**.

*   **Display & Headlines (Noto Serif):** These are your "Editorial Voices." Use `display-lg` and `headline-md` for collection titles and brand names. The serif evokes the masthead of a high-fashion magazine.
*   **Body & Titles (Inter):** These are your "Functional Voices." Use `title-sm` and `body-md` for product descriptions, prices, and navigation. Inter provides the legibility required for high-conversion e-commerce.
*   **Visual Hierarchy:** Always pair a large Serif headline with a significantly smaller Sans-serif sub-headline. The drastic jump in scale (e.g., `headline-lg` next to `label-md`) creates the "High-End" look common in luxury branding.

---

## 4. Elevation & Depth
In this design system, depth is "baked in" rather than "dropped on."

*   **The Layering Principle:** We use **Tonal Layering**. To highlight a product card, do not use a shadow. Instead, place a `surface-container-lowest` (`#ffffff`) card on top of a `surface-container` (`#f0eded`) background. This creates a soft, natural "lift."
*   **Ambient Shadows:** If an element must float (like a Quick-Add button), use an ultra-diffused shadow: `Y: 20, Blur: 40, Spread: 0`, with the color set to `on-surface` (`#323233`) at **4% opacity**.
*   **Glassmorphism:** For the iOS TabBar and NavigationBar, use a semi-transparent `surface` color with a `backdrop-blur` of 20px. This allows product imagery to subtly bleed through the navigation, making the UI feel like a single, cohesive canvas.

---

## 5. Components

### Buttons
*   **Primary:** Hard-edged (`0px` radius). Background: `primary`. Text: `on-primary`. Note: Padding should be generous (e.g., `spacing-4` vertical, `spacing-8` horizontal) to create a "Plinth" effect.
*   **Secondary/Tertiary:** No background. Use `title-sm` typography with a `secondary` color. Underline only on hover/active states using a `spacing-px` height.

### Input Fields
*   **Architecture:** No enclosing box. Use a `surface-variant` (`#e4e2e2`) bottom-only stroke (Ghost Border at 20% opacity). 
*   **States:** On focus, the stroke transitions to `secondary` (Gold). Error states use `error` (`#9f403d`) text only, no red boxes.

### Cards & Lists
*   **The "No-Divider" Rule:** Vertical white space from our `spacing-6` or `spacing-8` scale must be used to separate list items. 
*   **Product Cards:** Images must be the full width of the container. Typography (Brand/Price) should be left-aligned with a `spacing-2.5` margin. 

### Navigation Bar (iOS)
*   **Styling:** Transparent or `surface` with backdrop blur. 
*   **Typography:** Use `title-md` (Inter) for the center title, or `headline-sm` (Noto Serif) if the title is leading-aligned for a magazine feel.

---

## 6. Do's and Don'ts

### Do:
*   **Use 0px Corner Radii:** Everything in this system is sharp and architectural. Roundness dilutes the "High-Fashion" authority.
*   **Embrace Asymmetry:** Place a product image at 60% width on the left, and the next one at 60% width on the right.
*   **Prioritize Negative Space:** If a screen feels "busy," increase the spacing between elements using the `spacing-12` or `spacing-16` tokens.

### Don't:
*   **Don't use 1px borders:** Rely on background color shifts (`surface-container` tiers) to define areas.
*   **Don't use standard iOS blue:** All interactive elements must use the `primary` or `secondary` tokens.
*   **Don't crowd imagery:** Every product image needs a "breathing zone" of at least `spacing-4`. 
*   **Don't use high-opacity shadows:** If you can "see" the shadow clearly, it’s too dark. It should be felt, not seen.