DESCRIPTION
==========================================================
This library contains code for estimating minimum distance models.

The main classes in the library are:

- MdeModel: An abstract class that provides a template for minimum distance models and defines key methods such as Estimate().

- MdeData: A class that defines dataset objects.

- MdeEstimationOutput: A class that defines the output of the estimation routine.

To implement a model, the user defines a subclass of the abstract class MdeModel. A valid implementation must specifiy the model's parameters. It must also implement a function that returns a distance vector for given dataset and parameters.

The library includes an implementation of MdeModel: LinearGMMModel(). It can be used as "off-the-shelf" estimation tools. It can also serve as examples to guide users in implementing their own models.

To get a quick look at how to use the library, browse /test/testMdeModel.m. For more detailed documentation, open Matlab, make sure /gslab_mde/m/ is on the path, and type "doc MdeModel" followed by "doc MdeData" and "doc MdeEstimationOutput."

NOTES
==========================================================
- Use of this folder requires gslab_model
- The linear GMM output with instruments does not match exactly with Stata for small data sets (<1000 observations). 

REFERENCES
==========================================================
- Maximization problems are solved using KNITRO (http://www.ziena.com/knitro.htm).
- Formulas for estimation are adapted from Newey and McFadden 1994 (http://www.econ.brown.edu/fac/Frank_Kleibergen/ec266/chap36neweymacfadden.pdf).