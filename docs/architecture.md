# System Architecture and Design Decisions

## 1. Architectural Overview

The proposed system is designed as a **decision-level power limiting module**, intended to operate alongside conventional Battery Management System (BMS) components.

The neuro-fuzzy controller does not directly replace low-level protection mechanisms, but rather complements them by providing **adaptive and interpretable power limitation decisions** under normal operating conditions.

---

## 2. Separation Between Safety and Intelligence Layers

In industrial BMS architectures, **critical battery conditions** are typically handled through **hard safety constraints** implemented outside adaptive control logic.

In this project, such conditions are explicitly excluded from the neuro-fuzzy inference system:

> *Critical battery conditions are handled as hard safety constraints outside the neuro-fuzzy inference system, reflecting common industrial BMS architectures.*

This design choice ensures that:

* Safety-critical decisions remain deterministic.
* The neuro-fuzzy system operates only within safe and meaningful regions.
* Learning-based behavior does not override protection logic.

---

## 3. Role of the Neuro-Fuzzy System

The neuro-fuzzy module operates as a **supervisory decision layer**, estimating a **State of Power (SOP) limit** based on battery state and driving conditions.

Its purpose is to:

* Smooth power limitation transitions.
* Adapt to non-linear operating patterns.
* Maintain interpretability through fuzzy rule structures.

---

## 4. Input Space Modeling & Engineering Rationale

The input variables are modeled using fuzzy sets designed to reflect physical battery constraints and optimize ANFIS learning convergence (using 3 sets instead of 4 to reduce parameter explosion).

### 4.1 State of Charge (SoC) Design
The SoC variable uses a mix of Trapezoidal and Triangular membership functions to model distinct operational zones:

* **Low (0-40%) - Trapezoidal:**
    * **Rationale:** Represents the **Deep Discharge Protection** zone.
    * **Design:** A trapezoidal shape saturates at 1 (max membership) between 0-20% to enforce strict power limiting, while the slope from 20-40% ensures a smooth transition to normal operation, preventing control oscillation.

* **Normal (25-85%) - Triangular:**
    * **Rationale:** Represents the **Chemical Stability** zone.
    * **Design:** Peaks at **55%**, which typically correlates with optimal internal resistance and minimal thermal stress in Li-ion chemistries. The triangular shape implies that "normality" decreases as the system moves away from this thermodynamic sweet spot.

* **High (70-100%) - Trapezoidal:**
    * **Rationale:** Represents the **Regenerative Braking Saturation** zone.
    * **Design:** The function activates early (at 70%) to allow the system to anticipate saturation. As SoC approaches 100%, the battery's ability to accept current (regenerative braking) drops to zero; the neuro-fuzzy system uses this region to derate input power limits progressively.

The SoC linguistic term "Normal" represents the nominal electrochemical operating window of the battery, rather than a statistical midpoint. This terminology improves interpretability and aligns with industrial BMS conventions.

### 4.2 Battery Temperature Modeling

**Domain:**  
- Temperature range: 20 °C – 120 °C

Battery temperature is a critical variable influencing both **power capability** and **long-term degradation**. While extreme thermal conditions are handled by hard safety constraints, the neuro-fuzzy system operates within non-critical regions to **anticipate thermal stress and apply progressive power derating**.

The temperature input is modeled using three linguistic categories to balance interpretability and control resolution.

#### Linguistic Labels
- {Cold, Ideal, Hot}

---

#### Membership Function Design

**Cold (Trapezoidal)**  
- Approximate range: 20 °C – 35 °C  
- Rationale:  
  Low temperatures increase internal resistance and reduce instantaneous power delivery. In this region, the control strategy prioritizes battery heating and limits aggressive power demands to prevent voltage sag and efficiency losses.  
  A trapezoidal function ensures full activation at very low temperatures, with a smooth transition toward normal operation as temperature increases.

---

**Ideal (Triangular)**  
- Approximate range: 30 °C – 50 °C (peak around 40 °C)  
- Rationale:  
  This region represents the optimal thermal operating window under load, where electrochemical efficiency is high and thermal stress is minimized.  
  The triangular shape reflects that optimal behavior decreases progressively as the system moves away from this thermal equilibrium point.

---

**Hot (Trapezoidal)**  
- Approximate range: 45 °C – 120 °C  
- Rationale:  
  Elevated temperatures accelerate aging mechanisms and increase the risk of thermal runaway if left unmanaged.  
  The membership function activates early (around 45 °C) to enable **anticipatory power derating**, allowing the system to reduce thermal load before hard protection thresholds are reached.  
  Temperatures exceeding the safe operational envelope are handled exclusively by the hard safety layer, outside the neuro-fuzzy controller.

---

#### Design Considerations

- Membership functions intentionally overlap to ensure smooth transitions and avoid control oscillations.
- Thermal runaway and extreme over-temperature events are explicitly excluded from the fuzzy inference system.
- The design supports gradual power limitation rather than abrupt cut-offs, improving drivability and system stability.

### 4.3 Driving Style Modeling

**Domain:**  
- Normalized range: [0, 1]

Driving style is modeled as a **normalized high-level indicator** representing the dynamic load behavior imposed by the driver. Raw vehicle dynamics are processed externally to compute a Driving Style Index (DSI), which serves as the input to the neuro-fuzzy inference system.

This abstraction decouples sensor-level variability from control logic, while preserving sensitivity to aggressive load patterns.

---

#### Linguistic Labels
- {Smooth, Normal, Aggressive}

---

#### Membership Function Design

**Smooth (Trapezoidal)**  
- Approximate range: 0.0 – 0.4  
- Rationale:  
  Represents stable and predictable driving behavior with low current transients.  
  A trapezoidal function ensures full membership for consistently smooth driving, while allowing a gradual transition as dynamic behavior increases.

---

**Normal (Triangular)**  
- Approximate range: 0.3 – 0.7  
- Rationale:  
  Represents typical real-world driving behavior.  
  The triangular shape reflects that moderate driving is most representative around the center of this range, decreasing progressively toward both smoother and more aggressive styles.

---

**Aggressive (Trapezoidal)**  
- Approximate range: 0.6 – 1.0  
- Rationale:  
  Represents highly dynamic driving characterized by frequent power transients and elevated thermal stress.  
  Early activation of this region enables anticipatory power derating before safety limits are reached.

---

#### Design Considerations

- Overlapping membership functions ensure smooth adaptation to changing driving behavior.
- The use of trapezoidal functions for extreme behaviors (Smooth and Aggressive) improves robustness against noise.
- The neuro-fuzzy system leverages this varia

### 4.4 Output Variable: State of Power (SOP) Limit

**Domain:**  
- Normalized range: [0, 1]

The output of the neuro-fuzzy inference system is a **State of Power (SOP) limit**, representing the maximum allowable power that the battery system can safely deliver or absorb under current operating conditions.

Rather than commanding power directly, the controller provides a supervisory power envelope, which can be enforced by lower-level control and protection layers within the BMS.

---

#### Linguistic Labels
- {Limited, Nominal, Full}

---

#### Membership Function Design

**Limited (Trapezoidal)**  
- Approximate range: 0.0 – 0.45  
- Rationale:  
  Represents operating conditions where power must be significantly restricted due to thermal stress, low state of charge, or highly dynamic driving behavior.  
  A trapezoidal function ensures stable limitation and avoids oscillatory behavior near critical regions.

---

**Nominal (Triangular)**  
- Approximate range: 0.35 – 0.75  
- Rationale:  
  Represents standard operating conditions where a balance between performance, efficiency, and battery longevity is achieved.  
  The triangular shape reflects that nominal operation is most representative around the center of this range.

---

**Full (Trapezoidal)**  
- Approximate range: 0.65 – 1.0  
- Rationale:  
  Represents conditions where full power availability is permissible, typically characterized by healthy SoC, optimal temperature, and smooth or moderate driving behavior.  
  Early deactivation of this region prevents unnecessary stress under marginal conditions.

---

#### Design Considerations

- The SOP limit is enforced downstream by power electronics and vehicle control systems.
- Overlapping membership functions ensure smooth transitions between power levels.
- Safety-critical overrides remain outside the neuro-fuzzy inference system.

### 4.5 Fuzzy Rule Base

The neuro-fuzzy inference system employs a compact yet expressive rule base designed to supervise battery power availability under varying operational conditions.

The rule formulation follows a conservative design philosophy, where the most restrictive condition dominates the final power decision.

---

#### Rule Structure

Rules are expressed using a Mamdani-type formulation:

IF (SoC is X) AND (Temperature is Y) AND (Driving Style is Z)  
THEN (SOP Limit is W)

---

#### Critical Protection Rules

These rules ensure battery safety and system longevity and have implicit priority over performance-oriented rules:

- **R1:** IF Temperature is Hot → SOP Limit is Limited  
- **R2:** IF SoC is Low → SOP Limit is Limited  
- **R3:** IF Driving Style is Aggressive → SOP Limit is Limited  

---

#### Nominal Operation Rules

- **R4:** IF SoC is Normal AND Temperature is Ideal AND Driving Style is Normal → SOP Limit is Nominal  
- **R5:** IF SoC is High AND Temperature is Ideal AND Driving Style is Normal → SOP Limit is Nominal  

---

#### Full Power Enablement Rule

- **R6:** IF SoC is High AND Temperature is Ideal AND Driving Style is Economic → SOP Limit is Full  

---

#### Transitional Rules

- **R7:** IF SoC is Normal AND Temperature is Ideal AND Driving Style is Economic → SOP Limit is Nominal  
- **R8:** IF SoC is High AND Temperature is Cold → SOP Limit is Nominal  

---

#### Inference and Defuzzification

- Inference Method: Mamdani  
- AND Operator: Minimum  
- OR Operator: Maximum  
- Implication: Minimum  
- Aggregation: Maximum  
- Defuzzification Method: Centroid of Area


## 5. Scope and Assumptions

* The system assumes that all inputs are pre-validated by the BMS.
* Extreme fault conditions (thermal runaway, short circuits) are outside the scope.
* The model focuses on energy efficiency and degradation mitigation rather than fault detection.

---

## 6. Implications for Future Integration

By separating safety constraints from adaptive logic, the proposed architecture is compatible with:

* Hardware-in-the-loop (HIL) testing.
* Real-time embedded deployment.
* Integration with existing BMS software stacks.
* Offline simulation-based validation
* Rule surface inspection