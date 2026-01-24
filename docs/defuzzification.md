# Defuzzification Strategy

## Overview

The neuro-fuzzy controller produces a fuzzy output representing the activation degree of each **State of Power (SOP)** linguistic label.  
To interface with vehicle control and power electronics, this fuzzy result must be converted into a continuous scalar value.

---

## Selected Inference and Defuzzification Method

The system employs a **Mamdani-type inference mechanism** combined with **centroid-based defuzzification (Center of Area)**.

This choice prioritizes interpretability, smooth control behavior, and alignment with industrial fuzzy control practices.

---

## Centroid Defuzzification

The defuzzified SOP value is computed as:

\[
SOP^* = \frac{\int_{0}^{1} x \cdot \mu_{SOP}(x)\, dx}{\int_{0}^{1} \mu_{SOP}(x)\, dx}
\]

Where \( \mu_{SOP}(x) \) represents the aggregated output membership function.

---

## Rationale

Centroid defuzzification offers the following advantages:

- Continuous and smooth power derating
- Robustness to noisy or fluctuating inputs
- Avoidance of abrupt power transitions
- Clear physical interpretation

These characteristics are essential for automotive power management systems.

---

## Integration Considerations

- Defuzzification is executed at the supervisory control level.
- Hard safety constraints may further limit the resulting SOP.
- The final SOP value acts as a scaling factor applied to the maximum allowable power request.

---
