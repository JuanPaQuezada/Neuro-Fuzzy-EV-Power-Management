from src.fuzzy_system import create_fuzzy_controller


def run_example():
    print("---Initializing Neuro-Fuzzy Power Supervisor---")
    sim = create_fuzzy_controller()
    inputs={
        'soc' : 70,
        'temperature' : 38,
        'driving_style' : 0.45
    }
    print(f"Inputs: {inputs}")
    
    sim.input['soc']=inputs['soc']
    sim.input['temperature']=inputs['temperature']
    sim.input['driving_style']=inputs['driving_style']
    sim.compute()
    print("SOP Limit:", sim.output['sop'])


if __name__ == "__main__":
    run_example()
