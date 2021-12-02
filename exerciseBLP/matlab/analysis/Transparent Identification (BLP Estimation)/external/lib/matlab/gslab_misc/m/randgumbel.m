%RANDGUMBEL Gumbel (Type-I extreme value) distributed pseudorandom numbers.
%   R = RANDGUMBEL(N) returns an N-by-N matrix containing pseudorandom values drawn
%   from the standard Gumbel distribution with mu = 0 and beta = 1.  RANDGUMBEL(M,N)
%   or RANDGUMBEL([M,N]) returns an M-by-N matrix.  RANDGUMBEL(M,N,P,...) or
%   RANDGUMBEL([M,N,P,...]) returns an M-by-N-by-P-by-... array.  RANDGUMBEL returns a
%   scalar.  RANDGUMBEL(SIZE(A)) returns an array the same size as A.
%
%   Note: The size inputs M, N, P, ... should be nonnegative integers.
%   Negative integers are treated as 0.

function X = randgumbel(varargin)
    X = gumbelinv(rand(varargin{:}),0,1);
end