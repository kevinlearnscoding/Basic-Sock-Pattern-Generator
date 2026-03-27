# Backend Integration Guide

This guide explains how to convert the shell script into a web-based backend and integrate it with a frontend.

## Architecture Overview

```
Frontend (HTML/React/Vue)
        ↓
    HTTP/REST API
        ↓
Backend (Node.js/Python/Go)
        ↓
Pattern Generator (Core Logic)
        ↓
Template Engine
        ↓
Output (JSON/HTML/PDF)
```

## Phase 1: Backend Refactoring

### 1.1 Extract Core Functions

Create a language-agnostic module with pure functions:

**JavaScript Example** (`sockCalculator.js`):
```javascript
class SockCalculator {
  static calculateCastOn(circumference, gaugeSpi, gaugeWidth = 1) {
    let stitches = (circumference * gaugeSpi) / gaugeWidth;
    if (stitches % 2 !== 0) stitches--;
    return Math.round(stitches);
  }

  static calculateLegRounds(length, gaugeRpi, gaugeHeight = 1) {
    return Math.round((length * gaugeRpi) / gaugeHeight);
  }

  static calculateCuffRounds(length, gaugeRpi, gaugeHeight = 1) {
    return Math.round((length * gaugeRpi) / gaugeHeight);
  }

  static calculateToeStitches(castOn) {
    let toeRounds = Math.round(castOn / 3);
    if (toeRounds % 2 !== 0) toeRounds--;
    return {
      toeRounds: toeRounds,
      toePerNeedle: toeRounds / 2
    };
  }

  static calculateHeelStitches(castOn) {
    let heelStitches = Math.round(castOn / 2);
    let heelWrapStitches = Math.round(heelStitches / 3);
    if (heelWrapStitches % 2 !== 0) heelWrapStitches--;
    return {
      heelStitches: heelStitches,
      heelWrapStitches: heelWrapStitches,
      heelPerNeedle: heelWrapStitches / 2
    };
  }

  static cmToInches(cm) {
    return (cm / 2.54).toFixed(1);
  }

  static inchesToCm(inches) {
    return (inches * 2.54).toFixed(1);
  }

  static womensSizeToDimensions(size) {
    const length = ((size + 21) / 3) * 0.9;
    const circumference = 7.5 + (size * 0.08);
    return { length: length.toFixed(1), circumference: circumference.toFixed(1) };
  }

  static mensSizeToDimensions(size) {
    const length = ((size + 22) / 3) * 0.9;
    const circumference = 8.0 + (size * 0.08);
    return { length: length.toFixed(1), circumference: circumference.toFixed(1) };
  }
}

module.exports = SockCalculator;
```

### 1.2 Input Validation Layer

Create a validation module separate from calculations:

```javascript
class SockValidator {
  static validateFootSize(input) {
    if (input.length < 7 || input.length > 14) {
      throw new Error('Foot length must be between 7-14 inches');
    }
    if (input.circumference < 6 || input.circumference > 12) {
      throw new Error('Foot circumference must be between 6-12 inches');
    }
    return true;
  }

  static validateGauge(gauge) {
    if (gauge.spi <= 0) throw new Error('SPI must be greater than 0');
    if (gauge.rpi <= 0) throw new Error('RPI must be greater than 0');
    return true;
  }

  // ... validation methods
}
```

### 1.3 Pattern Generation Module

```javascript
class PatternGenerator {
  constructor(config) {
    this.config = config;
    this.validate();
    this.calculateAll();
  }

  validate() {
    SockValidator.validateConstructionMethod(this.config.construction_method);
    SockValidator.validateMeasurementUnits(this.config.measurement_units);
    SockValidator.validateFootSize(this.config.foot);
    SockValidator.validateGauge(this.config.gauge);
    // ... validate all sections
  }

  calculateAll() {
    this.calculations = {
      castOn: SockCalculator.calculateCastOn(
        this.config.foot.circumference_inches,
        this.config.gauge.stitches_per_inch,
        this.config.gauge.gauge_width
      ),
      legRounds: SockCalculator.calculateLegRounds(
        this.config.lengths.leg_inches,
        this.config.gauge.rows_per_inch,
        this.config.gauge.gauge_height
      ),
      cuffRounds: SockCalculator.calculateCuffRounds(
        this.config.lengths.cuff_inches,
        this.config.gauge.rows_per_inch,
        this.config.gauge.gauge_height
      ),
      ...SockCalculator.calculateToeStitches(this.castOn),
      ...SockCalculator.calculateHeelStitches(this.castOn)
    };
  }

  generate() {
    const pattern = this.renderTemplate();
    return {
      pattern,
      calculations: this.calculations,
      config: this.config
    };
  }

  renderTemplate() {
    // Render sections in order based on construction method
    if (this.config.construction_method === 'toe-up') {
      return this.renderToeUp();
    } else {
      return this.renderCuffDown();
    }
  }

  renderToeUp() {
    // Structure: TOE → FOOT → HEEL → LEG → CUFF → (optional AFTERTHOUGHT HEEL)
    let pattern = this.templates.header;
    pattern += this.renderToeSection();
    pattern += this.renderFootSection();
    pattern += this.renderHeelSetup();
    pattern += this.renderLegSection();
    pattern += this.renderCuffSection();
    if (this.config.pattern.heel === 'afterthought') {
      pattern += this.renderAftertoughtHeelInstructions();
    }
    return pattern;
  }

  renderCuffDown() {
    // Structure: CUFF → LEG → HEEL → FOOT → TOE → (optional AFTERTHOUGHT HEEL)
    let pattern = this.templates.header;
    pattern += this.renderCuffSection();
    pattern += this.renderLegSection();
    pattern += this.renderHeelSetup();
    pattern += this.renderFootSection();
    pattern += this.renderToeSection();
    if (this.config.pattern.heel === 'afterthought') {
      pattern += this.renderAftertoughtHeelInstructions();
    }
    return pattern;
  }

  // ... render individual sections based on templates
}
```

## Phase 2: REST API

### 2.1 Express.js Server Example

```javascript
const express = require('express');
const SockCalculator = require('./sockCalculator');
const PatternGenerator = require('./patternGenerator');

const app = express();
app.use(express.json());

// Generate complete pattern
app.post('/api/v1/socks/generate', (req, res) => {
  try {
    const generator = new PatternGenerator(req.body);
    const result = generator.generate();
    res.json({ success: true, data: result });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: error.message
    });
  }
});

// Quick calculations only
app.post('/api/v1/socks/calculate', (req, res) => {
  try {
    const { foot, gauge, lengths } = req.body;
    const castOn = SockCalculator.calculateCastOn(
      foot.circumference_inches,
      gauge.stitches_per_inch,
      gauge.gauge_width
    );
    const legRounds = SockCalculator.calculateLegRounds(
      lengths.leg_inches,
      gauge.rows_per_inch,
      gauge.gauge_height
    );
    const cuffRounds = SockCalculator.calculateCuffRounds(
      lengths.cuff_inches,
      gauge.rows_per_inch,
      gauge.gauge_height
    );
    const toe = SockCalculator.calculateToeStitches(castOn);
    const heel = SockCalculator.calculateHeelStitches(castOn);

    res.json({
      success: true,
      data: {
        castOn,
        legRounds,
        cuffRounds,
        ...toe,
        ...heel
      }
    });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
});

// Size conversions
app.get('/api/v1/socks/sizes/womens/:size', (req, res) => {
  const size = parseFloat(req.params.size);
  const dimensions = SockCalculator.womensSizeToDimensions(size);
  res.json({ success: true, data: dimensions });
});

app.get('/api/v1/socks/sizes/mens/:size', (req, res) => {
  const size = parseFloat(req.params.size);
  const dimensions = SockCalculator.mensSizeToDimensions(size);
  res.json({ success: true, data: dimensions });
});

app.listen(3000, () => console.log('Server running on port 3000'));
```

### 2.2 Flask/Python Example

```python
from flask import Flask, request, jsonify
from sock_calculator import SockCalculator
from pattern_generator import PatternGenerator

app = Flask(__name__)

@app.route('/api/v1/socks/generate', methods=['POST'])
def generate_pattern():
    try:
        config = request.json
        generator = PatternGenerator(config)
        result = generator.generate()
        return jsonify({'success': True, 'data': result})
    except ValueError as e:
        return jsonify({'success': False, 'error': str(e)}), 400

@app.route('/api/v1/socks/calculate', methods=['POST'])
def calculate():
    try:
        data = request.json
        calculations = {
            'castOn': SockCalculator.calculate_cast_on(
                data['circumference'],
                data['gauge_spi']
            ),
            # ... more calculations
        }
        return jsonify({'success': True, 'data': calculations})
    except (KeyError, ValueError) as e:
        return jsonify({'success': False, 'error': str(e)}), 400

@app.route('/api/v1/socks/sizes/womens/<float:size>', methods=['GET'])
def womens_size(size):
    dimensions = SockCalculator.womens_size_to_dimensions(size)
    return jsonify({'success': True, 'data': dimensions})

if __name__ == '__main__':
    app.run(debug=True, port=3000)
```

## Phase 3: Frontend Integration

### 3.1 React Component Example

```jsx
import React, { useState } from 'react';
import SockForm from './components/SockForm';
import PatternDisplay from './components/PatternDisplay';

function SockGenerator() {
  const [pattern, setPattern] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const handleFormSubmit = async (config) => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch('/api/v1/socks/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(config)
      });

      if (!response.ok) {
        throw new Error('Failed to generate pattern');
      }

      const data = await response.json();
      setPattern(data.data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="sock-generator">
      <h1>Sock Pattern Generator</h1>
      <SockForm
        onSubmit={handleFormSubmit}
        disabled={loading}
      />
      {error && <div className="error">{error}</div>}
      {pattern && <PatternDisplay pattern={pattern} />}
    </div>
  );
}

export default SockGenerator;
```

### 3.2 Vue Component Example

```vue
<template>
  <div class="sock-generator">
    <h1>Sock Pattern Generator</h1>
    <SockForm
      @submit="generatePattern"
      :disabled="loading"
    />
    <div v-if="error" class="error">{{ error }}</div>
    <PatternDisplay v-if="pattern" :pattern="pattern" />
  </div>
</template>

<script>
import SockForm from './components/SockForm.vue';
import PatternDisplay from './components/PatternDisplay.vue';

export default {
  components: { SockForm, PatternDisplay },
  data() {
    return {
      pattern: null,
      loading: false,
      error: null
    };
  },
  methods: {
    async generatePattern(config) {
      this.loading = true;
      this.error = null;

      try {
        const response = await fetch('/api/v1/socks/generate', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(config)
        });

        if (!response.ok) {
          throw new Error('Failed to generate pattern');
        }

        const data = await response.json();
        this.pattern = data.data;
      } catch (err) {
        this.error = err.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>
```

## Phase 4: Output Formats

### 4.1 Plain Text Output

```javascript
generatePlainText(pattern, calculations) {
  return `
SOCK KNITTING PATTERN
Cast on: ${calculations.castOn} stitches
Leg rounds: ${calculations.legRounds}
...
  `.trim();
}
```

### 4.2 HTML Output

```javascript
generateHTML(pattern, calculations) {
  return `
    <div class="sock-pattern">
      <h2>Sock Knitting Pattern</h2>
      <section>
        <h3>Stitch Counts</h3>
        <ul>
          <li>Cast on: ${calculations.castOn} stitches</li>
          <li>Leg rounds: ${calculations.legRounds}</li>
        </ul>
      </section>
      ...
    </div>
  `;
}
```

### 4.3 JSON Output

```javascript
generateJSON(pattern, calculations, config) {
  return {
    pattern: pattern,
    calculations: calculations,
    config: config,
    generated_at: new Date().toISOString()
  };
}
```

### 4.4 PDF Output

```javascript
const PDFDocument = require('pdfkit');

generatePDF(pattern, calculations) {
  const doc = new PDFDocument();
  doc.fontSize(20).text('Sock Pattern');
  doc.fontSize(12).text(pattern);
  return doc;
}
```

## Migration Checklist

- [ ] Extract calculation functions from shell script
- [ ] Create validation module
- [ ] Create pattern generator class
- [ ] Write unit tests for calculations (90%+ coverage)
- [ ] Build REST API endpoints
- [ ] Test API with cURL / Postman
- [ ] Create OpenAPI/Swagger spec
- [ ] Build form components
- [ ] Build pattern display component
- [ ] Create end-to-end tests
- [ ] Add error handling and user feedback
- [ ] Performance testing
- [ ] Security review (input validation, rate limiting)
- [ ] Deploy backend to cloud (Vercel, Heroku, AWS)
- [ ] Deploy frontend to CDN
- [ ] Add analytics tracking
- [ ] Set up monitoring and logging

## Performance Optimization

- Cache shoe size conversions (rarely change)
- Lazy-load pattern templates
- Use IndexedDB for client-side caching
- Minify patterns before transmission
- Consider gzip compression
- Use CDN for static assets

## Testing Strategy

```javascript
// Unit tests for calculations
describe('SockCalculator', () => {
  it('calculates cast-on correctly', () => {
    const castOn = SockCalculator.calculateCastOn(8, 7, 1);
    expect(castOn).toBe(56);
  });

  it('rounds to even number', () => {
    const castOn = SockCalculator.calculateCastOn(8.5, 7, 1);
    expect(castOn % 2).toBe(0);
  });
});

// Integration tests for full flow
describe('Pattern Generation', () => {
  it('generates complete pattern', async () => {
    const config = { /*...*/ };
    const generator = new PatternGenerator(config);
    const pattern = generator.generate();
    expect(pattern.pattern).toContain('Cast on');
  });
});
```

## Documentation Generation

Use JSDoc/Sphinx to auto-generate API docs:

```javascript
/**
 * Calculate the number of stitches to cast on
 * @param {number} circumference - Foot circumference in inches
 * @param {number} gaugeSpi - Stitches per inch
 * @param {number} gaugeWidth - Width measurement for gauge (default 1)
 * @returns {number} Cast-on stitch count (always even)
 */
static calculateCastOn(circumference, gaugeSpi, gaugeWidth = 1) {
  // ...
}
```

Generate docs with: `jsdoc` or build Swagger UI.

## Future Enhancements

1. **User Accounts**: Save favorite patterns, materials library
2. **Pattern Sharing**: Share patterns with other knitters
3. **Community Patterns**: Library of popular patterns
4. **AI Suggestions**: Recommend patterns based on yarn
5. **Mobile App**: React Native or Flutter wrapper
6. **Offline Version**: Progressive Web App (PWA)
7. **Video Tutorials**: Embedded instruction videos
8. **Gauge Calculator**: AI-powered gauge measurement from photos

---

Ready to migrate? Start with Phase 1 to extract and test the business logic, then move to API development, then frontend.
