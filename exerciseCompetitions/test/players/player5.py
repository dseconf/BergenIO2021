import numpy as np

class player:
    name = 'pmin'
    def __init__(self): 
        self.i = None
    
    def play(self, state, history):
        i = self.i
        pmin,pmax = state['actions'][i]
        return pmin