


The code implements the RGB to HSV/HSL/CMYK conversion module as specified, with the following key components:

### File Structure
- **rtl/rgb_color_space_conversion.sv**: Verilog module for the conversion core.
- **docs/specification.md**: Provides algorithmic details.
- **rtl/rgb_color_space_conversion.sv**: Contains the module definition, input/output ports, and pipeline logic.

---

### Key Implementation Highlights
1. **Scaling and Initialization**:
   - RGB inputs are scaled to 12-bit fixed-point values.
   - Max/min RGB values (`i_max`, `i_min`) are tracked.
   - Delta (`delta_i`) is calculated as the difference between max and min.

2. **Hue Calculation**:
   - Uses precomputed inverse values for `i_max` and `delta_i`.
   - Adjusts for RGB color channels (Red, Green, Blue).

3. **Saturation & Value**:
   - Saturation is derived from the max-min delta.
   - Value is the maximum RGB component.

4. **Lightness**:
   - Computed as `(i_max + i_min) / 2`.

5. **CMYK Conversion**:
   - Uses precomputed inverse values for `i_max`.
   - Scales differences appropriately to produce fixed-point values.

6. **Pipeline Control**:
   - All operations are synchronized to the clock (`clk`).
   - State machine transitions (e.g., `valid_in_shreg`, `l_scaled`) control data flow.

---

### Example Memory Usage (Simplified)
