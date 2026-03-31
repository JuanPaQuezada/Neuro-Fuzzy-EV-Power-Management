# Neuro-Fuzzy-EV-Power-Management
Neuro-fuzzy (ANFIS) power management system for electric vehicles using simulated BMS data

This project focuses on the design and simulation of a **neuro-fuzzy decision system** for **power limitation in electric vehicles**, inspired by concepts commonly found in **Battery Management Systems (BMS)**.

The objective is to estimate and dynamically adjust a **State of Power (SOP) limit** based on battery condition and driving behavior, using a **Takagi–Sugeno neuro-fuzzy approach (ANFIS)**.
The system is developed as a **software-based prototype**, prioritizing **engineering reasoning, interpretability, and adaptability** over hardware-specific implementation.

---

## 2. Engineering Motivation

Battery systems in electric vehicles operate under conditions characterized by:

* Non-linear dynamics
* Measurement uncertainty
* Strong dependence on thermal and load profiles

Conventional threshold-based logic is simple and interpretable but lacks adaptability, while purely data-driven approaches often behave as black boxes.

This project explores a **hybrid solution**, where:

* Fuzzy logic encodes expert knowledge and safety constraints
* Neural learning mechanisms adapt system parameters to data-driven patterns

The result is a control-oriented decision layer that balances **robustness, transparency, and flexibility**.

---

## 3. System Overview

The system evaluates battery and driving conditions and outputs a power limitation factor intended to reduce thermal and electrical stress while maintaining acceptable vehicle performance.

```
Battery & Driving Conditions
(SoC, Temperature, Driving Style)
            ↓
Fuzzy Inference System
(Mamdani baseline)
            ↓
Neuro-Fuzzy Model
(Takagi–Sugeno / ANFIS)
            ↓
State of Power Limit (SOP)
```

---

## 4. Input Variables

| Variable              | Range     | Description                                                      |
| --------------------- | --------- | ---------------------------------------------------------------- |
| State of Charge (SoC) | 0–100 %   | Represents the available battery energy                          |
| System Temperature    | 20–120 °C | Emphasis on critical regions associated with battery degradation |
| Driving Style Index   | 0–1       | Normalized indicator of load dynamics and driving aggressiveness |

The **Driving Style Index** abstracts current fluctuations and dynamic load profiles into a single normalized variable suitable for learning-based systems.

### 4.1 Data Preprocessing & Feature Scaling

Currently, the data presented in the previous section shows the raw or operational ranges of the variables. However, temperature values, driving metrics, and SoC percentages have drastically different scales and magnitudes. There is a strong scale imbalance: system temperature reaches up to 120 and SoC up to 100, while the driving style index has a maximum of 1. If the data is introduced to the model in this raw format, the model will destabilize. It will assign disproportionate importance to temperature and SoC simply because their numerical values are larger, almost completely ignoring the driving style.

Furthermore, introducing features with vastly differing scales can cause numerical instability during model training. Multiplying very large values by the model's weights can cause them to grow too rapidly, leading to floating-point overflow. Therefore, keeping numbers small and standardized makes it easier to control the learning process. For the data to be genuinely useful for training a predictive model, a mathematical transformation must be applied so that all variables share the same range, ideally between 0 and 1 or -1 and 1 (Kinsley & Kukieła, 2020).

To achieve this, the normalization parameters (such as minimum and maximum values) are defined strictly using the training dataset. This identical scaling transformation is consistently applied to the validation and testing datasets to prevent data leakage. 

The following scaling methods were applied to the system's inputs:

* **Driving Style Index (Range: 0–1)**
  * *Scaling Method:* None required (already normalized).
  * *Formula:* `Index_norm = Index`

* **State of Charge / SoC (Range: 0–100 %)**
  * *Scaling Method:* Linear scaling by dividing by the maximum absolute value.
  * *Formula:* `SoC_norm = SoC / 100`

* **System Temperature (Range: 20–120 °C)**
  * *Scaling Method:* Min-Max Scaling to stretch the values into a bounded `[3]` range.
  * *Formula:* `Temp_norm = (Temp - 20) / (120 - 20) = (Temp - 20) / 100`

---

## 5. Output Variable

| Variable                   | Range   | Description                                                         |
| -------------------------- | ------- | ------------------------------------------------------------------- |
| State of Power Limit (SOP) | 0–100 % | Upper bound on the power that can be safely delivered by the system |

The SOP output is designed to be mapped to downstream controllers (e.g., torque or current limits) in a real implementation.

---

## 6. Methodology

The development is carried out in two stages:

### 6.1 Classical Fuzzy System (Mamdani)

* Manually defined membership functions
* Expert-inspired rule base
* Used as a baseline for interpretability and behavior analysis

### 6.2 Neuro-Fuzzy System (Takagi–Sugeno / ANFIS)

* Parameterized membership functions
* Learning of premise and consequent parameters from data
* Improved smoothness and adaptability compared to the baseline model

---

## 7. Validation Approach

Due to the absence of physical vehicle hardware, validation is performed through:

* Model-based data simulation
* Scenario-driven testing (normal, stressed, and critical conditions)
* Comparative evaluation between classical fuzzy control and neuro-fuzzy control

This approach reflects early-stage development practices commonly used before hardware integration.

---

## 8. Project Status

* [x] Problem formulation
* [x] Definition of system variables
* [ ] Membership function design
* [ ] Rule base implementation
* [ ] ANFIS training
* [ ] Performance evaluation
* [ ] Results analysis and visualization

---

## 9. Limitations

* No direct access to real vehicle sensor data (CAN / OBD)
* Simplified thermal and electrical models
* Simulation-based validation only

These constraints are acknowledged and treated as part of a controlled proof-of-concept.

---

## 10. Future Work

* Integration with real or publicly available EV datasets
* Hardware-in-the-loop simulation
* Extension to regenerative braking and thermal control strategies
* Deployment-oriented design considerations

---

## 11. Author

**Juan Pablo Quezada**
B.Sc. in Intelligent Computing Engineering
Universidad Autónoma de Aguascalientes (UAA)

---

## 12. Disclaimer

This project is an independent academic and technical exercise and is not affiliated with or endorsed by any vehicle manufacturer.


---
## 13. References

Kinsley, H., & Kukieła, D. (2020). *Neural Networks from Scratch in Python*. Kinsley Enterprises Inc. https://nnfs.io
