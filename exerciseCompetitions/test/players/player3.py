import numpy as np

class player:
    name = 'Undercutting Bastard'
    def __init__(self): 
        self.i = None
    
    def play(self, state, history):
        i = self.i 
        j = 1-self.i 
        
        pmin,pmax = state['actions'][i]
        c = state['marginal_cost']
        delta = state['discount_factor']
        
        if len(history) == 0: 
            # initial play 
            p = pmax * 0.999 
        else: 
            p_lag = history[-1]
            pi_lag = p_lag[i]
            pj_lag = p_lag[j]
            
            # first idea: undercut by 10% 
            p = pj_lag * 0.9 
            
            # check if the price has gone too low 
            if (p - pmin) / (pmax - pmin) < 0.1: 
                # hike to maximum (hoping the friend follows)
                p = pmax
        
        FAIL = (p < pmin) or (p > pmax)
        if FAIL: 
            p = np.random.uniform(pmin, pmax)
        
        return p