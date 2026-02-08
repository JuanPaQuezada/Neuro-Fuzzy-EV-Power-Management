from skfuzzy import control as ctrl
from src.membership_functions import (
    create_soc,
    create_temperature,
    create_driving_style,
    create_sop
)


def create_fuzzy_controller():
    soc = create_soc()
    temp = create_temperature()
    ds = create_driving_style()
    sop = create_sop()

    rules = [
        # Safety is the priority, so these rules override everything. If the battery is cooking or dead, cut the power immediately
        ctrl.Rule(temp['hot'] | soc['low'], sop['limited']),
        # Also clamp down if the driver is too aggressive to save battery health
        ctrl.Rule(ds['aggressive'], sop['limited']),

        # Cold weather handling. Let it run normal, but physics won't let us peak here anyway
        ctrl.Rule(soc['high'] & temp['cold'], sop['nominal']),

        # Standard day-to-day operation. Everything looks good, so deliver nominal power
        ctrl.Rule(soc['normal'] & temp['ideal'] & ds['normal'], sop['nominal']),
        ctrl.Rule(soc['high'] & temp['ideal'] & ds['normal'], sop['nominal']),

        # Smooth transitions and efficiency. Keep it nominal even if driving smooth, unless we are topped up
        ctrl.Rule(soc['normal'] & temp['ideal'] & ds['smooth'], sop['nominal']),

        # Max performance mode. Only unlock full power if conditions are absolutely perfect
        ctrl.Rule(soc['high'] & temp['ideal'] & ds['smooth'], sop['full']),
    ]

    system = ctrl.ControlSystem(rules)
    return ctrl.ControlSystemSimulation(system)
