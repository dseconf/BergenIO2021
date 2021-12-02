# BLP with Verboven's car data

* The notebook, `blp_sandbox.ibynb`, provides the first steps towards estimating a BLP model from the ground up on real data. 
* `pyblp_ex.ibynp`: An example directly from `pyblp`, which replicates the original BLP estimates on that dataset (on cars in the US).

# Suggested exercises

## Just estimate the model 

Code up everything in the BLP estimator... but if it takes too long, consider focusing your time on one of the sub-tasks below. 

## Compare different algorithms for the nested fixed point: 

* Iterating on the contraction mapping (log-linear convergence)
* Newton-Raphson (should yield quadratic convergence, but at higher cost per iteration)
* SQUAREM: maybe quadratic convergence, but lower coding costs (jacobian not required)

## Compare logit variants 

Estimate the following
* Pure conditional logit, 
* Nested logit, 
* Random coefficients logit. 

Compare resulting estimates in terms of own- and cross-price elasticities. Present the Best Response graphs for two firms (e.g. in the same nest) to investigate implications for the degree of price competition among firms. 

## Explore the Price Equilibrium 

Once you have estimated a demand model, explore how the Price equilibrium works. 


