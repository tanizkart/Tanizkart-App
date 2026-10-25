# Tanizkart Design System: Royal Gold Quick-Commerce (Blinkit & Instamart Grade)

## 1. Brand Identity & Visual Philosophy
**Tanizkart** is a premier warehouse-direct quick-commerce mobile application delivering groceries, daily staples, fresh dairy, snacks, drinks, household goods, and personal care in 10–15 minutes.
- **Brand Tagline**: *"Save money save time"*
- **Official Brand Mark**: Blue metallic 3D shopping cart on the left, circular yellow-gold exchange arrows around "**TANIZ**" in Royal Blue (`#0052CC`) and "**KART**" in 3D Golden Amber (`#F5A623`), with the italicized tagline *"Save money save time"* below.
- **Vibe & Aesthetic**: High-energy, ultra-clean, mouth-watering quick-commerce inspired by **Blinkit**, **Swiggy Instamart**, and top Dribbble delivery concepts.
- **Surface Feel**: Clean, luminous, pure-white cards floating over soft slate-neutral canvas (`#F8FAFC`), paired with vibrant royal blue anchors, glossy gold conversion accents, and appetite-inducing close-up product visuals.

---

## 2. Color Palette & Semantics

| Token | Hex Value | Semantic Role |
|-------|-----------|---------------|
| `primary` | `#0052CC` / `#0B57D0` | Electric Royal Blue (Logo Cart & "TANIZ"). Brand header accents, active tabs, primary brand icons. |
| `primary-dark` | `#003D99` / `#0A1B3F` | Deep cobalt for high-contrast headers and floating cart containers. |
| `secondary` | `#F5A623` / `#FFB800` | Vibrant Warm Gold & Honey Amber (Logo "KART" & Arrows). Primary CTAs, "+ ADD" buttons, discount tags, conversion triggers. |
| `secondary-hover` | `#E09212` | Deeper gold on press / interaction. |
| `tertiary` | `#10B981` / `#059669` | Rapid Delivery Emerald Green. Used for `⚡ 10 MINS` badges, fresh cold-chain badges, instant savings pill. |
| `surface-canvas` | `#F8FAFC` | Light, crisp background for browsing shelves. |
| `surface-card` | `#FFFFFF` | Crisp pure white rounded cards (`border-radius: 18px`) with soft ambient shadows. |
| `surface-container-high`| `#EFF4FC` / `#EEF2FF` | Soft royal-blue tinted containers for highlights and offer banners. |
| `text-primary` | `#0F172A` | Deep charcoal for headlines, product titles, and active prices. |
| `text-secondary` | `#64748B` | Slate gray for weights, pack sizes, and MRP strikethroughs. |
| `border-subtle` | `#E8EDF5` | Hairline clean dividers, never harsh dark lines. |

---

## 3. Product Presentation: Close-up & Appetizing
- **Zoomed-in Hero Visuals**: Product packshots and food items must NOT be tiny thumbnails stranded in empty whitespace. They must be zoomed in, close-up, and filling 80–90% of the card's media zone with natural soft cast shadows.
- **Appetite & Lust Factor**: Items look crisp, fresh, and tangible—ready to be picked up.
- **Card Badges**: Sleek corner pill badges:
  - Top-left: `⚡ 10 MINS` (emerald or gold pill)
  - Top-right: `20% OFF` (vibrant gold badge) or wishlist heart

---

## 4. Navigation & Delivery Experience
- **Sleek Header Bar**:
  - Top line: `⚡ 10 MINS` pill badge + **Deliver to Home - Flat 302, Lawyerpet** with clean chevron ▾ (tap to switch address).
  - Profile icon & notification indicator right-aligned.
- **Search Experience**:
  - Pill search bar: "Search 'milk', 'chips', 'atta'..." with magnifying glass, voice mic, and barcode scanner.
- **Subtle Location Branding**:
  - NO repetitive, shouting "Ongole Central Warehouse" plastered across every card. Location is discreet, clean, and consumer-friendly like Blinkit/Instamart.

---

## 5. Typography: Plus Jakarta Sans
- **Headlines & Numbers**: Punchy, bold Plus Jakarta Sans with tight tracking (`-0.02em`).
- **Tabular Prices**: All prices (`₹`) enforce `font-variant-numeric: tabular-nums` to prevent layout shift.
- **Strike-through MRP**: Styled in muted slate with clear percentage savings (`Save ₹40`).

---

## 6. Component Specs

### 1. "+ ADD" / Stepper Pill
- **Default ("+ ADD")**: Crisp white pill with vibrant gold or royal blue border, bold text, and plus icon.
- **Active (`− 1 +`)**: Filled with vibrant golden amber (`#F5A623`), crisp deep text, tactile scale down on tap.

### 2. Floating Cart Dock
- **Container**: Sleek floating royal-navy pill dock (`#003D99` / `#0A1B3F`) elevated with soft drop shadow.
- **Left**: Item thumbnails preview + total amount (`₹205`) in tabular numbers.
- **Right**: Vibrant Gold CTA button ("View Cart →").

### 3. Promo & Category Banners
- Soft gradient backdrops (Royal Blue to Cobalt or Warm Amber to Gold) with high-res 3D grocery packshots breaking boundaries.

---

## 7. Stitch Prompt Block (Universal)

```text
Tanizkart quick-commerce app ('Save money save time') - Blinkit / Instamart premium style.
Brand Logo: 3D Blue Shopping Cart with circular yellow arrows, Royal Blue 'TANIZ' and 3D Golden Amber 'KART'.
Palette: Royal Blue (#0052CC), Golden Amber (#F5A623), Fresh Emerald (#10B981), Pure White (#FFFFFF), Slate (#F8FAFC).
Product Cards: Zoomed-in, close-up appetizing items filling the card container with soft shadows, 10 MINS delivery badge, and vibrant + ADD stepper pill.
Header: Sleek 10 MINS delivery bar with 'Deliver to Home - Flat 302, Lawyerpet ▾' and search bar. Subtle location (no shouting Ongole warehouse).
Device: Mobile (390px fluid viewport), Plus Jakarta Sans typography.
```
