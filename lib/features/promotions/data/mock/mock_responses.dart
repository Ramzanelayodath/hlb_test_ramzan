/// Raw API payloads from the brief. Kept as strings and decoded at runtime so
/// the real parsing path is exercised.
abstract final class MockResponses {
  static const success = '''
{
  "status": "SUCCESS",
  "payload": {
    "promotions": [
      {
        "id": "promo-001",
        "title": "2.88% p.a. Fixed Deposit",
        "description": "Lock in SGD 10,000 for 6 months.",
        "imageUrl": "https://picsum.photos/seed/promo1/400/200",
        "category": "DEPOSIT",
        "validFrom": "2026-10-01",
        "validUntil": "2026-12-31",
        "ctaLabel": "Apply now",
        "isFeatured": true
      },
      {
        "id": "promo-002",
        "title": "S\$30 Grab voucher",
        "description": "Spend S\$500 on your debit card.",
        "imageUrl": "https://picsum.photos/seed/promo2/400/200",
        "category": "CARD",
        "validFrom": "2026-10-01",
        "validUntil": "2026-10-31",
        "ctaLabel": "Learn more",
        "isFeatured": false
      },
      {
        "id": "promo-003",
        "title": "Zero FX markup",
        "description": "No FX markup on your first 3 overseas transfers.",
        "imageUrl": "https://picsum.photos/seed/promo3/400/200",
        "category": "TRANSFER",
        "validFrom": "2026-09-15",
        "validUntil": "2026-11-30",
        "ctaLabel": "Transfer now",
        "isFeatured": false
      },
      {
        "id": "promo-004",
        "title": "Refer a friend, earn S\$20",
        "description": "Earn S\$20 per successful referral.",
        "imageUrl": "https://picsum.photos/seed/promo4/400/200",
        "category": "REFERRAL",
        "validFrom": "2026-10-01",
        "validUntil": "2027-03-31",
        "ctaLabel": "Share now",
        "isFeatured": false
      }
    ]
  }
}
''';

  static const empty = '''
{ "status": "SUCCESS", "payload": { "promotions": [] } }
''';

  static const error = '''
{
  "status": "FAIL",
  "errorCode": "ERR_PROMOTIONS_UNAVAILABLE",
  "message": "Promotions are temporarily unavailable"
}
''';
}
