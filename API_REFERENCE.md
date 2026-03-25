# API Reference

This document details the functions and data structures used in the sock pattern generator, designed to facilitate backend API development.

## Data Structure

All user input is stored as shell variables. For web integration, these would become JSON objects:

```json
{
  "foot": {
    "length_inches": 9.5,
    "circumference_inches": 8.0
  },
  "gauge": {
    "stitches_per_inch": 7,
    "rows_per_inch": 10,
    "gauge_width": 1,
    "gauge_height": 1
  },
  "pattern": {
    "leg": "stockinette",  // or "1x1 ribbing", "2x2 ribbing"
    "toe": "short row",     // or "wedge"
    "heel": "short row"     // or "afterthought"
  },
  "lengths": {
    "leg_inches": 8,
    "cuff_inches": 2
  },
  "yarn": {
    "brand": "Patons",
    "weight": "Fingering",
    "color_dye_lot": "Color 123",
    "yardage_available": 400
  },
  "needles": {
    "size": "US 1",
    "method": "Magic Loop"  // or "DPNs", "Short Circulars"
  }
}
```

## Calculation Functions

These functions are pure and could be extracted into a stateless backend.

### `calculate_cast_on()`

**Input**: `FOOT_CIRCUMFERENCE`, `GAUGE_SPI`, `GAUGE_WIDTH`

**Output**: `CAST_ON` (integer, always even)

```javascript
// Pseudocode
castOn(circumference, gaugeSpi, gaugeWidth) {
  let stitches = (circumference * gaugeSpi) / gaugeWidth;
  // Round to even number
  if (stitches % 2 !== 0) stitches--;
  return Math.round(stitches);
}
```

**Purpose**: Determines how many stitches to cast on based on foot circumference and gauge.

### `calculate_leg_rounds()`

**Input**: `LEG_LENGTH`, `GAUGE_RPI`, `GAUGE_HEIGHT`

**Output**: `LEG_ROUNDS` (integer)

```javascript
legRounds(length, gaugeRpi, gaugeHeight) {
  return Math.round((length * gaugeRpi) / gaugeHeight);
}
```

### `calculate_cuff_rounds()`

**Input**: `CUFF_LENGTH`, `GAUGE_RPI`, `GAUGE_HEIGHT`

**Output**: `CUFF_ROUNDS` (integer)

```javascript
cuffRounds(length, gaugeRpi, gaugeHeight) {
  return Math.round((length * gaugeRpi) / gaugeHeight);
}
```

### `calculate_toe_stitches()`

**Input**: `CAST_ON`

**Output**: `TOE_ROUNDS` (integer)

```javascript
// Number of decrease rounds for toe
toeRounds(castOn) {
  return Math.round(castOn / 4);
}
```

### `calculate_heel_stitches()`

**Input**: `CAST_ON`

**Output**: `HEEL_STITCHES` (integer)

```javascript
heelStitches(castOn) {
  return Math.round(castOn / 2);
}
```

### `calculate_yardage_needed()`

**Input**: `CAST_ON`, `LEG_ROUNDS`, `CUFF_ROUNDS`, `TOE_ROUNDS`

**Output**: `ESTIMATED_YARDAGE` (integer)

```javascript
estimatedYardage(castOn, legRounds, cuffRounds, toeRounds) {
  let totalRounds = castOn * (legRounds + cuffRounds + toeRounds);
  // Rough estimate: ~600 stitches = 1 yard
  return Math.round(totalRounds / 600);
}
```

## Shoe Size Conversion Functions

### `compute_foot_length_from_womens_size()`

**Input**: `size` (US Women's shoe size)

**Output**: `FOOT_LENGTH`, `FOOT_CIRCUMFERENCE` (inches, decimals)

```javascript
womensSizeToDimensions(size) {
  const length = 8.125 + (size * 0.3125);
  const circumference = 7.5 + (size * 0.08);
  return {
    length: length.toFixed(1),
    circumference: circumference.toFixed(1)
  };
}
```

### `compute_foot_length_from_mens_size()`

**Input**: `size` (US Men's shoe size)

**Output**: `FOOT_LENGTH`, `FOOT_CIRCUMFERENCE` (inches, decimals)

```javascript
mensSizeToDimensions(size) {
  const length = 8.375 + (size * 0.3125);
  const circumference = 8.0 + (size * 0.08);
  return {
    length: length.toFixed(1),
    circumference: circumference.toFixed(1)
  };
}
```

## Validation Functions

For web integration, these functions should validate user input:

### Foot Size Validation

```javascript
validateFootSize(input) {
  // Custom dimensions
  if (input.length && input.circumference) {
    if (input.length < 7 || input.length > 14) return false;
    if (input.circumference < 6 || input.circumference > 12) return false;
    return true;
  }

  // Women's size
  if (input.womensSize) {
    return input.womensSize >= 5 && input.womensSize <= 13;
  }

  // Men's size
  if (input.mensSize) {
    return input.mensSize >= 5 && input.mensSize <= 16;
  }

  return false;
}
```

### Gauge Validation

```javascript
validateGauge(input) {
  if (input.method === 'standard') {
    return input.spi > 0 && input.rpi > 0;
  }

  if (input.method === 'custom') {
    return input.spi > 0 && input.rpi > 0 &&
           input.width > 0 && input.height > 0;
  }

  return false;
}
```

### Pattern Validation

```javascript
validatePattern(input) {
  const validLegs = ['stockinette', '1x1 ribbing', '2x2 ribbing'];
  const validToes = ['short row', 'wedge'];
  const validHeels = ['short row', 'afterthought'];

  return validLegs.includes(input.leg) &&
         validToes.includes(input.toe) &&
         validHeels.includes(input.heel);
}
```

## Pattern Generation

The pattern generation function is template-based. It could be refactored into:

1. **Template Engine**: Store pattern templates by type
2. **Variable Substitution**: Replace variables with calculated values
3. **Output Formatting**: Generate text, HTML, JSON, or PDF

### Suggested Template Structure

```
templates/
├── header.txt
├── sections/
│   ├── cuff.txt
│   ├── leg.txt
│   ├── heel_shortrow.txt
│   ├── heel_afterthought.txt
│   ├── toe_shortrow.txt
│   ├── toe_wedge.txt
│   └── finishing.txt
└── footer.txt
```

### Template Variables

Common variables that appear in templates:

| Variable | Description | Example |
|----------|-------------|---------|
| `{castOn}` | Cast-on stitch count | `180` |
| `{legRounds}` | Rounds for leg section | `60` |
| `{cuffRounds}` | Rounds for cuff section | `15` |
| `{heelStitches}` | Stitches for heel flap | `90` |
| `{legPattern}` | Pattern description | `Stockinette stitch` |

## REST API Endpoints (Proposed)

For web backend implementation:

```
POST /api/v1/socks/generate
  Input: Full config JSON
  Output: { pattern: string, config: object }

POST /api/v1/socks/calculate
  Input: measurements + gauge
  Output: { castOn, legRounds, cuffRounds, heelStitches, ... }

GET /api/v1/socks/sizes/womens/:size
  Output: { length, circumference }

GET /api/v1/socks/sizes/mens/:size
  Output: { length, circumference }

GET /api/v1/socks/validate
  Input: Section of config
  Output: { valid: boolean, errors: string[] }
```

## Error Handling

Functions should return structured errors:

```javascript
{
  success: false,
  error: 'Invalid gauge',
  field: 'gauge',
  message: 'Stitch gauge must be greater than 0',
  code: 'INVALID_GAUGE'
}
```

## Integration Checklist

When converting to backend:

- [ ] Extract each calculation function into standalone module
- [ ] Add input validation for each function
- [ ] Add error handling with structured error objects
- [ ] Create shoe size conversion API endpoints
- [ ] Create pattern generation endpoint(s)
- [ ] Add unit tests for all calculations
- [ ] Add integration tests for full pattern generation
- [ ] Document expected ranges for all inputs
- [ ] Add rate limiting / usage tracking if needed
- [ ] Create OpenAPI/Swagger specification
- [ ] Implement caching for shoe size conversions

## Performance Considerations

- Calculations are all O(1) - very fast
- Pattern generation is O(n) where n = total rounds (typically <500)
- No database queries needed for basic generation
- Could cache shoe size conversions
- Consider CDN for static pattern templates

## Security Considerations

- All user input should be validated
- Constraint inputs to reasonable ranges (prevent DOS via huge numbers)
- Sanitize filenames when allowing pattern export
- Consider rate limiting on generation endpoint
- Log generation requests for analytics
