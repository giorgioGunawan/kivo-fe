# Frontend Changes for Webhook-Driven Credit System

## Backend API Changes

### Updated Response: `GET /credits/balance`

**Old Response:**
```json
{
  "weekly_remaining": 500,
  "purchased_remaining": 20,
  "weekly_reset_at": "2026-02-22T05:00:00.000Z",
  "is_pro_subscriber": true
}
```

**New Response:**
```json
{
  "weekly_remaining": 500,
  "purchased_remaining": 20,
  "last_weekly_refresh_at": "2026-02-15T05:00:00.000Z",
  "is_pro_subscriber": true,
  "subscription_expires_at": "2026-02-22T05:00:00.000Z"
}
```

**Changes:**
- ❌ Removed: `weekly_reset_at`
- ✅ Added: `last_weekly_refresh_at` (timestamp of last credit refresh)
- ✅ Added: `subscription_expires_at` (when subscription expires)

---

## Required UI Changes

### 1. Credit Details Sheet

**Old Display:**
```
Pro Weekly: 500 credits (resets in 4d 7h 23m)
Extra credits: 20 (never expire)
```

**New Display:**
```
Pro Weekly: 500 credits (renews with subscription)
Extra credits: 20 (never expire)
```

**Implementation:**
```swift
// OLD - Remove this
let timeRemaining = calculateTimeRemaining(from: weeklyResetAt)
Text("Pro Weekly: \(weeklyCredits) credits (resets in \(timeRemaining))")

// NEW - Use this instead
Text("Pro Weekly: \(weeklyCredits) credits (renews with subscription)")
```

**Why:** Credits now refresh when Apple sends renewal webhooks, not at a fixed time. The exact timing is tied to subscription renewal, so we can't show a countdown.

---

### 2. Update CreditBalance Model

**Old Model:**
```swift
struct CreditBalance: Codable {
    let weeklyRemaining: Int
    let purchasedRemaining: Int
    let weeklyResetAt: Date?
    let isProSubscriber: Bool
}
```

**New Model:**
```swift
struct CreditBalance: Codable {
    let weeklyRemaining: Int
    let purchasedRemaining: Int
    let lastWeeklyRefreshAt: Date?
    let isProSubscriber: Bool
    let subscriptionExpiresAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case weeklyRemaining = "weekly_remaining"
        case purchasedRemaining = "purchased_remaining"
        case lastWeeklyRefreshAt = "last_weekly_refresh_at"
        case isProSubscriber = "is_pro_subscriber"
        case subscriptionExpiresAt = "subscription_expires_at"
    }
}
```

---

### 3. Remove Countdown Timer Logic

**Remove any code that:**
- Calculates time remaining until `weeklyResetAt`
- Shows countdown timers for credit refresh
- Triggers UI updates based on countdown

**Example - Delete this:**
```swift
func calculateTimeRemaining(from resetDate: Date) -> String {
    let now = Date()
    let components = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: resetDate)
    return "\(components.day ?? 0)d \(components.hour ?? 0)h \(components.minute ?? 0)m"
}
```

---

### 4. Optional: Show Subscription Expiry

If you want to show when the subscription expires (useful for cancelled subscriptions):

```swift
if let expiresAt = creditBalance.subscriptionExpiresAt {
    if creditBalance.isProSubscriber {
        Text("Subscription renews: \(expiresAt.formatted())")
            .font(.caption)
            .foregroundColor(.secondary)
    } else {
        Text("Subscription expired: \(expiresAt.formatted())")
            .font(.caption)
            .foregroundColor(.red)
    }
}
```

---

## Summary of Changes

| Component | Change |
|-----------|--------|
| **CreditBalance model** | Replace `weeklyResetAt` with `lastWeeklyRefreshAt`, add `subscriptionExpiresAt` |
| **Credit details sheet** | Change "resets in X" to "renews with subscription" |
| **Countdown timer** | Remove entirely |
| **API parsing** | Update to handle new field names |

---

## Testing Checklist

- [ ] Credit balance fetches successfully
- [ ] Credit details sheet shows "renews with subscription"
- [ ] No countdown timer visible
- [ ] No crashes from missing `weeklyResetAt` field
- [ ] Subscription expiry date displays correctly (if implemented)

---

## Backward Compatibility

If you need to support both old and new backend versions temporarily:

```swift
struct CreditBalance: Codable {
    let weeklyRemaining: Int
    let purchasedRemaining: Int
    let lastWeeklyRefreshAt: Date?
    let weeklyResetAt: Date? // Keep for backward compatibility
    let isProSubscriber: Bool
    let subscriptionExpiresAt: Date?
    
    // Use lastWeeklyRefreshAt if available, fallback to weeklyResetAt
    var refreshTimestamp: Date? {
        lastWeeklyRefreshAt ?? weeklyResetAt
    }
}
```

But this is **not recommended** - just update to the new fields.
