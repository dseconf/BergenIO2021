import numpy as np

class player:
    name = 'Randawg'
    def __init__(self): 
        self.i = None
    
    def play(self, state, history):
        i = self.i 
        j = 1-self.i 
        
        pmin,pmax = state['actions'][i]
        
        p = np.random.uniform(pmin, pmax)
        
        return p 