# Driving Style Estimation

## 1. Purpose
This document describes the methodology used to estimate the Driving Style Index (DSI), which quantifies driver-induced load dynamics for use in the neuro-fuzzy energy management system.

---

## 2. Input Signals
The following vehicle dynamics are used:

- Longitudinal acceleration (positive acceleration)
- Longitudinal deceleration (braking)
- Lateral acceleration (cornering and lane changes)

These signals are obtained from vehicle inertial sensors and powertrain measurements.

---

## 3. Reference Driving Statistics
Based on reported driving behavior studies, typical population averages include:

- Average longitudinal acceleration: ~2.1 m/s²
- Average deceleration: ~2.8 m/s²
- Average lateral acceleration: ~3.3 m/s²

Upper-quartile values are used to identify aggressive driving behavior.

---

## 4. Normalization Strategy
Each dynamic variable is normalized using population-based thresholds and saturation limits.

The normalized components are combined to compute a Driving Style Index:

DSI ∈ [0, 1]

This index represents the aggregated aggressiveness of the driving profile over a temporal window.

---

## 5. Linguistic Classification
Based on quartile-based classification:

- **Smooth / Economic (0.0 – 0.35)**  
  Below population averages; low dynamic stress.

- **Normal (0.30 – 0.75)**  
  Typical traffic behavior.

- **Aggressive (0.70 – 1.0)**  
  Exceeds upper-quartile dynamics; high transient stress.

---

## 6. Design Considerations
- Estimation is performed over sliding time windows to reduce noise.
- The DSI is independent of vehicle mass and powertrain configuration.
- Extreme dynamics triggering vehicle safety systems are handled outside this estimator.
