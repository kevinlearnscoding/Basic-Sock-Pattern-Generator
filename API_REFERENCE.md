# API Reference

This document details the functions and data structures used in the sock pattern generator, designed to facilitate backend API development.

## Data Structure

All user input is stored as shell variables. For web integration, these would become JSON objects:

```json
{
  "construction_method": "toe-up",  // or "cuff-down"
  "measurement_units": "imperial",  // or "metric"
  "foot": {
    "shoe_size": 8,
    "shoe_size_type": "Women's",
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
    "leg": "stockinette",      // or "1x1 ribbing", "2x2 ribbing"
    "cuff": "1x1 ribbing",     // or "2x2 ribbing"
    "toe": "short row",         // or "wedge"
    "heel": "short row"         // or "afterthought"
  },
  "lengths": {
    "leg_inches": 8,
    "cuff_inches": 2
  },
  "yarn": {
    "brand": "Patons",          // optional - can be empty
    "weight": "Fingering",      // optional - can be empty
    "color_dye_lot": "Color 123" // optional - can be empty
  },
  "needles": {
    "size": "US 1",
    "method": "Magic Loop"      // or "DPNs (Double-Pointed Needles)", "Short Circulars"
  }
}
```

**Note**: Yarn information is optional. Yardage calculations are no longer provided.

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

**Output**: `TOE_ROUNDS`, `TOE_PER_NEEDLE` (integers)

```javascript
// Toe stitches: approximately 1/3 of cast-on total
// For proportional stitch distribution across 2 needles
toeStitches(castOn) {
  let toeRounds = Math.round(castOn / 3);
  // Ensure even number
  if (toeRounds % 2 !== 0) toeRounds--;
  return {
    toeRounds: toeRounds,
    toePerNeedle: toeRounds / 2
  };
}
```

### `calculate_heel_stitches()`

**Input**: `CAST_ON`

**Output**: `HEEL_STITCHES`, `HEEL_WRAP_STITCHES`, `HEEL_PER_NEEDLE` (integers)

```javascript
// Heel flap stitches are half of cast-on
// Unwrapped/remaining stitches are approximately 1/3 of heel stitches
heelStitches(castOn) {
  let heelStitches = Math.round(castOn / 2);
  let heelWrapStitches = Math.round(heelStitches / 3);
  // Ensure even number
  if (heelWrapStitches % 2 !== 0) heelWrapStitches--;
  return {
    heelStitches: heelStitches,
    heelWrapStitches: heelWrapStitches,
    heelPerNeedle: heelWrapStitches / 2
  };
}
```

## Shoe Size Conversion Functions

### `compute_foot_length_from_womens_size()`

**Input**: `size` (US Women's shoe size, 5-13)

**Output**: `FOOT_LENGTH`, `FOOT_CIRCUMFERENCE` (inches, decimals)

```javascript
womensSizeToDimensions(size) {
  const length = ((size + 21) / 3) * 0.9;  // Negative ease at 90%
  const circumference = 7.5 + (size * 0.08);
  return {
    length: length.toFixed(1),
    circumference: circumference.toFixed(1)
  };
}
```

### `compute_foot_length_from_mens_size()`

**Input**: `size` (US Men's shoe size, 5-16)

**Output**: `FOOT_LENGTH`, `FOOT_CIRCUMFERENCE` (inches, decimals)

```javascript
mensSizeToDimensions(size) {
  const length = ((size + 22) / 3) * 0.9;  // Negative ease at 90%
  const circumference = 8.0 + (size * 0.08);
  return {
    length: length.toFixed(1),
    circumference: circumference.toFixed(1)
  };
}
```

## Utility Functions

### `cm_to_inches()`

**Input**: `centimeters` (number)

**Output**: Inches (decimal, 1 decimal place)

```javascript
cmToInches(cm) {
  return (cm / 2.54).toFixed(1);
}
```

### `inches_to_cm()`

**Input**: `inches` (number)

**Output**: Centimeters (decimal, 1 decimal place)

```javascript
inchesToCm(inches) {
  return (inches * 2.54).toFixed(1);
}
```

These are used to convert between imperial and metric measurements for user display.

## Validation Functions

For web integration, these functions should validate user input:

### Construction Method Validation

```javascript
validateConstructionMethod(method) {
  const valid = ['toe-up', 'cuff-down'];
  return valid.includes(method);
}
```

Valid methods determine which toe/heel options are available:
- **Toe-Up**: Toe (short row or wedge), Heel (short row or afterthought)
- **Cuff-Down**: Heel (short row or afterthought), Toe (short row or wedge)

### Measurement Units Validation

```javascript
validateMeasurementUnits(units) {
  const valid = ['imperial', 'metric'];
  return valid.includes(units);
}
```

Determines display units:
- **Imperial**: inches, yards
- **Metric**: centimeters, meters

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
  const validCuffs = ['1x1 ribbing', '2x2 ribbing'];
  const validToes = ['short row', 'wedge'];
  const validHeels = ['short row', 'afterthought'];

  const heelToeOptions = {
    'toe-up': {
      heels: ['short row', 'afterthought'],
      toes: ['short row', 'wedge']
    },
    'cuff-down': {
      heels: ['short row', 'afterthought'],
      toes: ['short row', 'wedge']
    }
  };

  return validLegs.includes(input.leg) &&
         validCuffs.includes(input.cuff) &&
         validToes.includes(input.toe) &&
         validHeels.includes(input.heel);
}

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
  Input: Full config JSON with construction_method and measurement_units
  Output: { pattern: string, calculations: object, config: object }

POST /api/v1/socks/calculate
  Input: measurements + gauge + construction_method + measurement_units
  Output: { castOn, legRounds, cuffRounds, heelStitches, heelWrapStitches, toeRounds, ... }

GET /api/v1/socks/sizes/womens/:size
  Output: { length, circumference }

GET /api/v1/socks/sizes/mens/:size
  Output: { length, circumference }

GET /api/v1/socks/validate/:section
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
