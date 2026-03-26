# 🧦 Basic Sock Pattern Generator

> **Create beautiful, custom knitting patterns for socks in seconds!**

A POSIX-compliant shell script that generates customized knitting patterns for basic socks. Users can specify foot measurements, gauge, pattern preferences, yarn details, and needle specifications to receive a complete knitting pattern with detailed instructions.

---

## ✨ Features

✅ **📏 Flexible Input Methods** - Enter foot size via shoe size (US Women's/Men's) or custom dimensions

✅ **📊 Gauge Options** - Input gauge as stitches/rows per inch or per custom measurement

✅ **🎨 Pattern Customization** - Mix and match:
   - Leg: Stockinette or Ribbing (1x1 or 2x2)
   - Toe: Short Row or Wedge
   - Heel: Short Row or Afterthought
   - Custom leg & cuff lengths

✅ **🧶 Yarn & Needle Details** - Track brand, weight, color/dye lot, yardage & needle specs

✅ **⚡ Smart Calculations** - Auto-calculates cast-on stitches, round counts & yardage

✅ **👀 Review & Edit** - Preview all choices before generating—edit anything on the fly

✅ **💾 Flexible Output** - Display on screen, save to file, or both

✅ **🖥️ POSIX Compliant** - Works on sh, bash, zsh, ksh, and more

✅ **🌍 Platform Independent** - Linux, macOS, WSL & other Unix-like systems

✅ **⚙️ Backend-Ready** - Modular architecture for web application integration

---

## 📋 Requirements

- **Shell**: POSIX-compliant shell (`sh`, `bash`, `zsh`, `ksh`, etc.)
- **Tools**: `awk` (standard POSIX utility), `clear`, `read`, `printf`
- **That's it!** 🎉 No external dependencies like `bc` required

---

## 🚀 Quick Start

```bash
# Make the script executable
chmod +x sock_pattern_generator.sh

# Run it!
./sock_pattern_generator.sh
```

Follow the interactive prompts to enter your sock specifications. The script will:

1. 📐 Gather measurements & preferences
2. 🧮 Calculate stitch counts automatically
3. 📋 Display a summary for review
4. ✏️ Let you make changes if needed
5. 📖 Generate a complete knitting pattern
6. 💾 Save the pattern or display it on screen

---

## 📚 Usage Guide

### 📏 Input Prompts

**🦶 Foot Size**
- Choose between US Women's shoe size, US Men's shoe size, or enter custom dimensions
- Script converts shoe size to foot length and circumference estimates

**📊 Gauge Information**
- Enter as stitches/rows per inch (standard) or per custom measurement width
- 💡 **Tip**: This is critical for accuracy—use an actual swatch!

**🎨 Pattern Choices**
- Leg pattern: Stockinette (smooth) or Ribbing (1x1 or 2x2)
- Toe: Short Row (wrap-and-turn) or Wedge (decrease-based)
- Heel: Short Row (wrap-and-turn) or Afterthought (pick up later)

**📏 Lengths**
- Leg length: From cuff to heel (typically 6-10 inches)
- Cuff length: Elastic band at top (typically 1-2 inches for ribbing)

**🧶 Yarn Details**
- Brand, weight (fingering, sport, DK, etc.), color/dye lot
- Total yardage available

**🪡 Needle Specifications**
- Size (US or mm), working method (DPNs, Magic Loop, or Short Circulars)

### ✅ Review Process

After entering all information:
1. Screen displays complete summary of all choices
2. Confirm to proceed or make changes
3. Can edit individual sections without re-entering everything
4. Once confirmed, pattern is generated immediately

### 📤 Output Options

- 🖥️ **Display**: View pattern in terminal
- 💾 **Save**: Write to text file (you choose the filename)
- ⚡ **Both**: Display and save simultaneously

## 📖 Pattern Output Contents

Generated patterns include everything you need:

- 📋 Project details (yarn info, needles used)
- 📐 Measurements and calculated gauge impact
- 🧮 All stitch counts (cast-on, by section, totals)
- 📝 Step-by-step instructions for each section:
  - **👑 Cuff**: Ribbing setup and rounds
  - **🦵 Leg**: Pattern instructions and round counts
  - **👠 Heel**: Detailed wrap-and-turn instructions (short row) or setup (afterthought)
  - **🦶 Foot**: From heel to toe opening
  - **🎯 Toe**: Complete decrease instructions with Kitchener stitch finishing
- ✨ Finishing techniques (weaving in ends, blocking, care)
- 📊 Estimated yardage requirements
- 🧼 Care instructions for finished socks

---

## 🔧 Technical Details

### 🧮 Calculation Formulas

```
Cast-on stitches = (foot circumference × SPI) / gauge width
Leg rounds = (leg length × RPI) / gauge height
Cuff rounds = (cuff length × RPI) / gauge height
```

Where SPI = stitches per inch, RPI = rows per inch

### 👟 Shoe Size Conversion

- **👩 US Women's**: Foot length = 8.125 + (size × 0.3125) inches
- **👨 US Men's**: Foot length = 8.375 + (size × 0.3125) inches

### 🏗️ Script Architecture

Organized into modular, maintainable sections:

| Component | Purpose |
|-----------|---------|
| **Utility Functions** | Screen management, headers, pauses |
| **Input Functions** | Gather user data (shoe size, gauge, preferences) |
| **Calculation Functions** | Math & stitch count generation |
| **Review Functions** | Summary display & edit flow |
| **Generation Functions** | Pattern creation & output formatting |
| **Main Flow** | Orchestrate entire user workflow |

---

## 📖 Examples

### 👩 Women's Size 8 with DK Yarn

```
Size: US Women's 8 (9.5" length, 8" circumference)
Gauge: 5 SPI, 6.5 RPI (typical for DK weight)
Pattern: Stockinette leg, 1x1 ribbed cuff
Toe: Wedge | Heel: Short Row
Needle: US 4 (3.5mm) Magic Loop
Leg: 8 inches | Cuff: 2 inches
```

✨ Result: ~180-200 stitches cast-on, ~900-1000 yards needed

### 👧 Child's Sock with Sport Yarn

```
Size: US Women's 5 (8" length, 6.5" circumference)
Gauge: 7 SPI, 9 RPI (Fingering weight)
Pattern: 2x2 ribbed leg, stockinette elsewhere
Toe: Short Row | Heel: Afterthought
Needle: US 2 (2.75mm) DPNs
Leg: 6 inches | Cuff: 1.5 inches
```

✨ Result: ~45 stitches cast-on, ~400-500 yards needed

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| ❌ Script won't run | `chmod +x sock_pattern_generator.sh` |
| 🧮 Calculations incorrect | Verify `awk` is available: `which awk` |
| 📊 Gauge measurements off | Verify gauge swatch (4"×4" minimum), re-measure carefully |
| 💾 Can't save files | Check directory permissions: `ls -ld .` |
| 🎨 Color codes in saved file | This is normal; colors don't affect pattern content |

---

## ✅ POSIX Compliance

This script uses **only POSIX-compliant features**:
- ✓ Standard shell built-ins only
- ✓ No bash-specific features (arrays, extended globs, etc.)
- ✓ Compatible with `sh`, `bash`, `zsh`, `ksh`, `dash`

Verify POSIX compliance:
```bash
sh -n sock_pattern_generator.sh  # Check syntax
sh sock_pattern_generator.sh     # Run with sh
```

---

## 📁 File Structure

```bash
Basic-Sock-Pattern-Generator/
├── sock_pattern_generator.sh      # Main POSIX shell script 🎯
├── test_pattern_generator.sh      # Automated test suite 🧪
├── README.md                       # This file 📖
├── QUICKSTART.md                   # Quick start guide 🚀
├── API_REFERENCE.md                # Function documentation 📚
├── BACKEND_INTEGRATION.md          # Web integration guide 🌐
└── LICENSE                         # MIT License ⚖️
```

---

## 🎯 Limitations & Future Roadmap

### 🚫 Current Limitations
- Basic sock construction (no lace, colorwork, or complex stitches yet)
- Single pair per pattern generation
- Approximate yardage estimates
- No calf shaping or advanced shaping options

### 🚀 Planned Features

🗓️ **Bulk Knitting Calculator** - Generate patterns for multiple pairs at once
   - Family matching sets
   - Gift sets in different sizes
   - Batch yardage calculations

📄 **PDF Pattern Export** - Create publication-ready PDFs
   - Professional formatting
   - Print-friendly layouts
   - Embedded stitch diagrams

---

## 🤝 Contributing

Have ideas? Found a bug? We'd love your help!

🐛 **Bug reports** - Open an issue with reproduction steps
💡 **Feature requests** - Tell us what you'd like to knit
🔧 **Pull requests** - Code contributions welcome

---

## 📄 License

[MIT License](LICENSE) - Use, modify, and distribute freely!

---

<div align="center">

### 🧦 Happy Knitting! 🧶

Made with ❤️ for knitters who love customization

---

**Need help?** → Check [QUICKSTART.md](QUICKSTART.md)
**For developers?** → See [BACKEND_INTEGRATION.md](BACKEND_INTEGRATION.md)</div>
