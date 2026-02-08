# Fuzzy Rule Base – Expert Knowledge Layer

## 1. Purpose of the Rule Base

This rule base encodes expert-level heuristic knowledge used by the neuro-fuzzy controller to determine an appropriate **State of Power (SOP) limit** under varying battery and driving conditions.

Rather than enforcing hard constraints, the rules provide **interpretable and smooth supervisory decisions**, complementing deterministic protection logic implemented elsewhere in the BMS.

---

## 2. Variables Involved

### Inputs
- **State of Charge (SoC):** {Low, Normal, High}
- **Battery Temperature:** {Cold, Ideal, Hot}
- **Driving Style:** {Smooth, Normal, Aggressive}

### Output
- **State of Power (SOP) Limit:** {Limited, Nominal, Full}

---

## 3. Rule Design Principles

The fuzzy rules are designed according to the following principles:

- **Thermal dominance:** Battery temperature has priority over all other variables.
- **Progressive derating:** Power limitations are applied gradually, not abruptly.
- **Behavior-aware control:** Aggressive driving modulates power availability but does not dominate safety.
- **Interpretability:** All rules reflect intuitive expert reasoning.

- **Human-expert reasoning:** The rule base explicitly models the qualitative decision-making process of experienced BMS engineers, translating physical intuition and operational heuristics into interpretable fuzzy logic rules rather than purely data-driven behavior.

---

## 4. Safety-Dominant Rules

These rules enforce conservative behavior whenever thermal or energy-related stress is present.

| Rule ID | SoC | Temperature | Driving Style | SOP |
|-------|-----|-------------|---------------|-----|
| R1 | Any | Hot | Any | Limited |
| R2 | Low | Any | Any | Limited |
| R3 | Low | Ideal | Any | Limited |
| R4 | Any | Hot | Aggressive | Limited |

**Rationale:**  
Thermal stress and low state of charge represent the highest degradation risk and therefore dominate power limitation decisions.

## 5. Nominal Operating Rules

These rules represent balanced operating conditions under which power availability is moderated but not restricted.

| Rule ID | SoC | Temperature | Driving Style | SOP |
|-------|-----|-------------|---------------|-----|
| R5 | Normal | Ideal | Normal | Nominal |
| R6 | Normal | Ideal | Aggressive | Nominal |
| R7 | High | Ideal | Normal | Nominal |
| R8 | High | Ideal | Aggressive | Nominal |

**Rationale:**  
These rules prevent excessive current draw or regeneration while preserving drivability under common conditions.

## 6. Performance-Oriented Rules

Full power availability is allowed only when all system variables indicate low stress.

| Rule ID | SoC | Temperature | Driving Style | SOP |
|-------|-----|-------------|---------------|-----|
| R9 | Normal | Ideal | Smooth | Full |
| R10 | High | Ideal | Smooth | Full |

**Rationale:**  
Smooth driving combined with optimal thermal and charge conditions minimizes internal resistance and thermal buildup.

## 7. Regenerative and High SoC Considerations

Near high State of Charge levels, the battery’s ability to safely accept regenerative current decreases due to rising cell voltage and thermal sensitivity.  
To prevent overvoltage stress while preserving drivability, the following rule is applied.

| Rule ID | SoC  | Temperature | Driving Style | SOP |
|--------|------|-------------|---------------|-----|
| R11 | High | Ideal | Any | Nominal |

**Rationale:**  
This rule enforces a moderate power limitation near full charge, reducing regenerative and discharge current stress without triggering aggressive derating.  
The behavior reflects common industrial BMS strategies used to protect cells during regenerative braking events.


## 8. Scope and limitations

*Extreme fault conditions are handled outside the fuzzy inference system.

*The rule base does not override hard BMS safety constraints.

*The system focuses on power availability and degradation mitigation rather than fault detection.

*Rule conflicts are resolved using Mamdani max–min inference and centroid defuzzification.*

