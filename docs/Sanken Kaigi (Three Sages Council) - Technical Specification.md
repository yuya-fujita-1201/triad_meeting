# Sanken Kaigi (Three Sages Council) - Technical Specification

## Project Overview

**App Name:** 三賢会議 (Sanken Kaigi / Three Sages Council)

**Tagline:** 3つの視点で、迷いを終わらせる (End your hesitation with 3 perspectives)

**Core Concept:** A decision-making support app where three AI personalities with different perspectives (Logic, Empathy, Intuition) deliberate and produce a "resolution card" to help users make confident decisions.

**Target Platform:** Mobile app (iOS/Android) - Start with web-based prototype using React Native or similar framework

---

## Design System

### Color Palette

**Primary Colors:**
- Background Gradient: `#F5F3FF` (light purple) → `#E8F4FF` (light blue)
- Card Background: `#FFFFFF` (white)
- Text Primary: `#2D3748` (dark grey)
- Text Secondary: `#718096` (medium grey)

**AI Personality Colors:**
- Logic (論理): `#4A5FD9` (deep blue)
- Empathy (共感): `#FF6B9D` (coral pink)
- Intuition (直感): `#FFB800` (golden yellow)

**Button Gradient:**
- Start: `#8B7FFF` (purple)
- End: `#5B9FFF` (blue)

**Additional Colors:**
- Input Border: `#E2E8F0` (light grey)
- Shadow: `rgba(0, 0, 0, 0.08)`

### Typography

**Font Family:**
- Primary: `Noto Sans JP` (for Japanese text)
- Fallback: `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`

**Font Sizes:**
- App Title: `28px`, Weight: `700` (Bold)
- Tagline: `14px`, Weight: `400` (Regular)
- AI Name: `18px`, Weight: `600` (Semi-bold)
- AI Subtitle: `12px`, Weight: `400` (Regular)
- Input Placeholder: `14px`, Weight: `400` (Regular)
- Button Text: `16px`, Weight: `600` (Semi-bold)

### Spacing & Layout

**Screen Padding:** `20px` (left/right)

**Component Spacing:**
- Between title and tagline: `8px`
- Between tagline and AI cards: `40px`
- Between AI cards: `16px` (vertical)
- Between AI cards and input: `32px`
- Between input and button: `24px`

**Card Dimensions:**
- Width: `calc(50% - 8px)` for bottom two cards (side by side)
- Top card: Full width minus padding
- Height: Auto (min `120px`)
- Border Radius: `16px`
- Shadow: `0 2px 8px rgba(0, 0, 0, 0.08)`

**AI Card Structure:**
- Left accent border: `4px` solid (color matches AI personality)
- Icon size: `48px × 48px`
- Padding: `20px`

---

## Screen 1: Home Screen (Initial State)

### Layout Structure

```
┌─────────────────────────────────────┐
│  Status Bar (system)                │
├─────────────────────────────────────┤
│                                     │
│         三賢会議                     │
│   3つの視点で、迷いを終わらせる      │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  📖  論理                    │   │
│  │      論点整理・合理判断      │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌──────────┐  ┌──────────────┐   │
│  │ ❤️  共感  │  │ ⚡ 直感      │   │
│  │ 気持ち・  │  │ ひらめき・  │   │
│  │ 人間関係  │  │ 次の一手    │   │
│  └──────────┘  └──────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 相談内容（1〜2文でOK）       │   │
│  │ 例：転職するか迷っています   │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │      会議を始める            │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

### Component Specifications

#### 1. App Title Section
```jsx
<View style={styles.headerContainer}>
  <Text style={styles.appTitle}>三賢会議</Text>
  <Text style={styles.tagline}>3つの視点で、迷いを終わらせる</Text>
</View>
```

**Styles:**
```css
.headerContainer {
  padding-top: 60px;
  padding-bottom: 40px;
  align-items: center;
}

.appTitle {
  font-size: 28px;
  font-weight: 700;
  color: #2D3748;
  font-family: 'Noto Sans JP', sans-serif;
  letter-spacing: 2px;
}

.tagline {
  font-size: 14px;
  font-weight: 400;
  color: #718096;
  margin-top: 8px;
  font-family: 'Noto Sans JP', sans-serif;
}
```

#### 2. AI Personality Cards

**Top Card (Logic):**
```jsx
<View style={[styles.aiCard, styles.aiCardFull, styles.logicCard]}>
  <Image source={LogicIcon} style={styles.aiIcon} />
  <View style={styles.aiTextContainer}>
    <Text style={styles.aiName}>論理</Text>
    <Text style={styles.aiSubtitle}>論点整理・合理判断</Text>
  </View>
</View>
```

**Bottom Cards (Empathy & Intuition):**
```jsx
<View style={styles.aiCardsRow}>
  <View style={[styles.aiCard, styles.aiCardHalf, styles.empathyCard]}>
    <Image source={EmpathyIcon} style={styles.aiIcon} />
    <Text style={styles.aiName}>共感</Text>
    <Text style={styles.aiSubtitle}>気持ち・人間関係</Text>
  </View>
  
  <View style={[styles.aiCard, styles.aiCardHalf, styles.intuitionCard]}>
    <Image source={IntuitionIcon} style={styles.aiIcon} />
    <Text style={styles.aiName}>直感</Text>
    <Text style={styles.aiSubtitle}>ひらめき・次の一手</Text>
  </View>
</View>
```

**Styles:**
```css
.aiCard {
  background-color: #FFFFFF;
  border-radius: 16px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  align-items: center;
}

.aiCardFull {
  width: 100%;
  margin-bottom: 16px;
}

.aiCardHalf {
  width: calc(50% - 8px);
}

.aiCardsRow {
  flex-direction: row;
  justify-content: space-between;
  margin-bottom: 32px;
}

.logicCard {
  border-left: 4px solid #4A5FD9;
}

.empathyCard {
  border-left: 4px solid #FF6B9D;
}

.intuitionCard {
  border-left: 4px solid #FFB800;
}

.aiIcon {
  width: 48px;
  height: 48px;
  margin-bottom: 12px;
}

.aiName {
  font-size: 18px;
  font-weight: 600;
  color: #2D3748;
  margin-bottom: 4px;
  font-family: 'Noto Sans JP', sans-serif;
}

.aiSubtitle {
  font-size: 12px;
  font-weight: 400;
  color: #718096;
  text-align: center;
  font-family: 'Noto Sans JP', sans-serif;
}
```

#### 3. Input Field

```jsx
<TextInput
  style={styles.inputField}
  placeholder="相談内容（1〜2文でOK）&#10;例：転職するか迷っています"
  placeholderTextColor="#A0AEC0"
  multiline={true}
  numberOfLines={4}
/>
```

**Styles:**
```css
.inputField {
  width: 100%;
  background-color: #FFFFFF;
  border-radius: 12px;
  border: 1px solid #E2E8F0;
  padding: 16px;
  font-size: 14px;
  color: #2D3748;
  min-height: 100px;
  text-align-vertical: top;
  font-family: 'Noto Sans JP', sans-serif;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}
```

#### 4. Start Button

```jsx
<TouchableOpacity style={styles.startButton} onPress={handleStartMeeting}>
  <Text style={styles.buttonText}>会議を始める</Text>
</TouchableOpacity>
```

**Styles:**
```css
.startButton {
  width: 100%;
  background: linear-gradient(90deg, #8B7FFF 0%, #5B9FFF 100%);
  border-radius: 12px;
  padding: 16px;
  align-items: center;
  box-shadow: 0 4px 12px rgba(139, 127, 255, 0.3);
}

.buttonText {
  font-size: 16px;
  font-weight: 600;
  color: #FFFFFF;
  font-family: 'Noto Sans JP', sans-serif;
}
```

---

## Icon Specifications

**IMPORTANT: DO NOT USE EMOJI. Use SVG icons or PNG images.**

### Logic Icon (論理)
- **Concept:** Open book with graph/chart overlay
- **Style:** Line art, minimal, 2px stroke
- **Color:** `#4A5FD9` (deep blue)
- **Format:** SVG or PNG (48×48px, @2x and @3x for mobile)

### Empathy Icon (共感)
- **Concept:** Heart with gentle radiating lines
- **Style:** Line art, minimal, 2px stroke
- **Color:** `#FF6B9D` (coral pink)
- **Format:** SVG or PNG (48×48px, @2x and @3x for mobile)

### Intuition Icon (直感)
- **Concept:** Lightning bolt with sparkle/star
- **Style:** Line art, minimal, 2px stroke
- **Color:** `#FFB800` (golden yellow)
- **Format:** SVG or PNG (48×48px, @2x and @3x for mobile)

**Icon Generation Instructions:**
1. Generate three separate icon images using the specifications above
2. Save as SVG for scalability, or PNG at 144×144px (for @3x density)
3. Ensure transparent background
4. Use consistent stroke width (2px) across all icons
5. Center the icon within the 48×48px canvas

---

## Background Gradient Implementation

```css
.screenBackground {
  background: linear-gradient(180deg, #F5F3FF 0%, #E8F4FF 100%);
  min-height: 100vh;
}
```

**For React Native:**
```jsx
import LinearGradient from 'react-native-linear-gradient';

<LinearGradient
  colors={['#F5F3FF', '#E8F4FF']}
  style={styles.container}
>
  {/* Content */}
</LinearGradient>
```

---

## Interaction Specifications

### Button States

**Normal:**
- Background: Linear gradient `#8B7FFF` → `#5B9FFF`
- Shadow: `0 4px 12px rgba(139, 127, 255, 0.3)`

**Pressed:**
- Background: Linear gradient `#7A6FEE` → `#4A8FEE` (10% darker)
- Shadow: `0 2px 6px rgba(139, 127, 255, 0.3)`
- Scale: `0.98`

**Disabled:**
- Background: `#CBD5E0` (grey)
- Shadow: None
- Opacity: `0.6`

### Input Field States

**Normal:**
- Border: `1px solid #E2E8F0`
- Background: `#FFFFFF`

**Focused:**
- Border: `2px solid #8B7FFF`
- Background: `#FFFFFF`
- Shadow: `0 0 0 3px rgba(139, 127, 255, 0.1)`

---

## Implementation Notes

### Technology Stack Recommendations
- **Framework:** React Native (for iOS/Android) or React (for web prototype)
- **State Management:** React Context API or Zustand
- **UI Components:** Custom components (avoid emoji-based icons)
- **Fonts:** Google Fonts (Noto Sans JP)
- **Icons:** Custom SVG or PNG assets (generated separately)

### File Structure
```
/src
  /components
    AICard.jsx
    InputField.jsx
    StartButton.jsx
  /screens
    HomeScreen.jsx
  /assets
    /icons
      logic.svg
      empathy.svg
      intuition.svg
  /styles
    colors.js
    typography.js
    spacing.js
  /utils
    api.js (for AI integration)
```

### Responsive Considerations
- Test on iPhone SE (small), iPhone 14 Pro (standard), iPhone 14 Pro Max (large)
- Ensure cards don't become too small on narrow screens
- Consider single-column layout for screens < 360px width

### Accessibility
- Ensure color contrast ratio meets WCAG AA standards (4.5:1 for normal text)
- Add `accessibilityLabel` to all interactive elements
- Support dynamic text sizing
- Ensure touch targets are at least 44×44px

---

## Next Screens (Future Implementation)

### Screen 2: Deliberation Screen
- Show three AI avatars "thinking"
- Display progress indicator
- Show sequential AI responses (not all at once)

### Screen 3: Resolution Card Screen
- Display final decision card with:
  - Resolution (推奨/保留/情報不足)
  - Votes from each AI (賛成/反対 + reasoning)
  - Assumptions used
  - Risks identified
  - Next steps (3 action items)
  - Review deadline
- Share button for SNS
- Save to history button

### Screen 4: History Screen
- List of past consultations
- Search and filter by tags
- Review past decisions

---

## AI Integration Specifications

### API Endpoint Structure
```
POST /api/deliberate
{
  "query": "転職するか迷っています。現職は安定していますが、やりがいを感じません。",
  "mode": "standard" // or "comparison" for A/B choices
}

Response:
{
  "resolution": {
    "decision": "推奨A",
    "votes": {
      "logic": { "vote": "賛成", "reasoning": "..." },
      "empathy": { "vote": "賛成", "reasoning": "..." },
      "intuition": { "vote": "保留", "reasoning": "..." }
    },
    "assumptions": ["..."],
    "risks": ["..."],
    "next_steps": ["...", "...", "..."],
    "review_date": "2026-01-27"
  }
}
```

### AI Personality Prompts

**Logic (論理):**
```
あなたは「論理」という人格のAIです。
データ、コスト、確率、再現性を重視して判断してください。
感情に流されず、客観的な事実に基づいて意見を述べてください。
```

**Empathy (共感):**
```
あなたは「共感」という人格のAIです。
人間関係、感情、後悔しない選び方を重視して判断してください。
相手の気持ちや周囲への影響を考慮して意見を述べてください。
```

**Intuition (直感):**
```
あなたは「直感」という人格のAIです。
直感、スピード、突破口、行動を重視して判断してください。
考えすぎずに、今すぐできる次の一手を提案してください。
```

---

## Design Fidelity Requirements

- Match the provided mockup image exactly for colors, spacing, and layout
- Use the specified color codes (`#F5F3FF`, `#4A5FD9`, etc.) without variation
- Use Noto Sans JP font for all Japanese text
- DO NOT use emoji for icons - generate custom SVG/PNG assets
- Maintain consistent border radius (16px for cards, 12px for inputs/buttons)
- Ensure shadows are subtle and match specifications

---

## Testing Checklist

- [ ] Colors match specification exactly
- [ ] Fonts render correctly (Noto Sans JP)
- [ ] Icons are custom SVG/PNG (no emoji)
- [ ] Layout matches mockup on multiple screen sizes
- [ ] Input field accepts multi-line text
- [ ] Button gradient renders correctly
- [ ] Touch targets are at least 44×44px
- [ ] Accessibility labels are present
- [ ] Background gradient renders smoothly

---

## Deliverables

1. Functional home screen matching the design specification
2. Custom icon assets (SVG or PNG) for Logic, Empathy, Intuition
3. Reusable component library (AICard, InputField, StartButton)
4. Responsive layout that works on iOS and Android
5. Clean, well-documented code following React/React Native best practices

---

**End of Specification**
