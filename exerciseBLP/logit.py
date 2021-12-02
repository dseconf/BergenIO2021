import numpy as np 
import pandas as pd 

def q(theta, y, x): 
    '''q(theta,y,x): criterion function: L2 error'''
    assert theta.ndim == 1
    assert y.ndim == 2 
    assert x.ndim == 3 

    N,J,K = x.shape 
    assert (y.shape[0] == N) and (y.shape[1] == J), 'y and x do not conform '
    assert theta.size == K, 'x and theta do not conform'

    market_shares = choice_prob(theta, x) # (N,J)

    I = (market_shares < 1e-8)
    if np.any(I): 
        market_shares[I] = 1e-8

    diff_sq = (y - np.log(market_shares)) ** 2

    return diff_sq.flatten()

def starting_values(y, x): 
    assert x.ndim == 3 
    N,J,K = x.shape
    theta0 = np.zeros((K,))
    return theta0

def util(theta, x, MAXRESCALE=True): 
    '''util: compute the deterministic part of utility, v, and max-rescale it
    Args. 
        theta: (K,) vector of parameters 
        x: (N,J,K) matrix of covariates 
        MAXRESCALE (optional): bool, we max-rescale if True (the default)
    
    Returns
        v: (N,J) matrix of (deterministic) utility components
    '''
    assert theta.ndim == 1 
    N,J,K = x.shape 

    # deterministic utility 
    v = x @ theta # (N,J) 

    if MAXRESCALE: 
        # subtract the row-max from each observation
        v -= v.max(axis=1, keepdims=True)  # keepdims maintains the second dimension, (N,1), so broadcasting is successful
    
    return v 

def ccp_of_v(v): 
    # denominator 
    denom = np.exp(v).sum(axis=1, keepdims=True) # (N,1)
    
    # Conditional choice probabilites
    ccp = np.exp(v) / denom

    return ccp 

def choice_prob(theta, x):
    '''choice_prob(): Computes the (N,J) matrix of choice probabilities 
    Args. 
        theta: (K,) vector of parameters 
        x: (N,J,K) matrix of covariates 
    
    Returns
        ccp: (N,J) matrix of probabilities 
    '''
    assert theta.ndim == 1, f'theta should have ndim == 1, got {theta.ndim}'
    N, J, K = x.shape
    
    # deterministic utility 
    v = util(theta, x)
    
    # conditional choice probabilities 
    ccp = ccp_of_v(v)
    
    return ccp


# analytic gradients
def dccp_dtheta(theta, x): 
    N,J,K = x.shape
    v = util(theta, x)
    ccp = (ccp_of_v(v)).reshape(N,J,1)
    
    dv_dtheta = x 
    deriv = ccp * (dv_dtheta - (ccp*dv_dtheta).sum(1,keepdims=True))
    
    return deriv

def dq(theta,y,x): 
    N,J,K = x.shape
    
    ms = choice_prob(theta, x)

    I = ms == 0.0
    if I.any(): 
        ms[I] = 1e-8
        
    L2 = (y - np.log(ms))**2
    
    dL2_dccp = -2*(y-np.log(ms))/ms
    
    dq_dtheta = dL2_dccp.reshape(N,J,1) * dccp_dtheta(theta,x)
    
    return dq_dtheta.reshape(N*J,K)

def ddq(theta,y,x): 
    '''Hessian, by the outer product of the scores'''
    N,J,K = x.shape
    s = dq(theta,y,x)
    H = s.T@s/N
    return H 