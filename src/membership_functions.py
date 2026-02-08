import numpy as np
import skfuzzy as fuzz
from skfuzzy import control as ctrl


def create_soc():
    soc = ctrl.Antecedent(np.arange(0, 101, 1), 'soc')
    soc['low'] = fuzz.trapmf(soc.universe, [0, 0, 20, 40])
    soc['normal'] = fuzz.trimf(soc.universe, [25, 55, 85])
    soc['high'] = fuzz.trapmf(soc.universe, [70, 80, 100, 100])
    return soc


def create_temperature():
    temp = ctrl.Antecedent(np.arange(20, 121, 1), 'temperature')
    temp['cold'] = fuzz.trapmf(temp.universe, [20, 20, 25, 35])
    temp['ideal'] = fuzz.trimf(temp.universe, [30, 40, 50])
    temp['hot'] = fuzz.trapmf(temp.universe, [45, 60, 120, 120])
    return temp


def create_driving_style():
    ds = ctrl.Antecedent(np.arange(0, 1.01, 0.01), 'driving_style')
    ds['smooth'] = fuzz.trapmf(ds.universe, [0, 0, 0.2, 0.4])
    ds['normal'] = fuzz.trimf(ds.universe, [0.3, 0.5, 0.7])
    ds['aggressive'] = fuzz.trapmf(ds.universe, [0.6, 0.8, 1, 1])
    return ds


def create_sop():
    sop = ctrl.Consequent(np.arange(0, 1.01, 0.01), 'sop')
    sop['limited'] = fuzz.trapmf(sop.universe, [0, 0, 0.3, 0.45])
    sop['nominal'] = fuzz.trimf(sop.universe, [0.35, 0.55, 0.75])
    sop['full'] = fuzz.trapmf(sop.universe, [0.65, 0.8, 1, 1])
    
    sop.defuzzify_method = 'centroid'
    return sop
