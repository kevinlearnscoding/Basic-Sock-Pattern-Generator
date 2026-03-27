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

## 🤝 Contributing

Have ideas? Found a bug? We'd love your help!

🐛 **Bug reports** - Open an issue with reproduction steps
💡 **Feature requests** - Tell us what you'd like to knit
🔧 **Pull requests** - Code contributions welcome

---

## 📄 License

[BSD-2 License](LICENSE) - Use, modify, and distribute freely!

---

<div align="center">

### 🧦 Happy Knitting! 🧶

Made with ❤️ for knitters who love customization

---

**Need help?** → Check [QUICKSTART.md](QUICKSTART.md)
**For developers?** → See [BACKEND_INTEGRATION.md](BACKEND_INTEGRATION.md)</div>
