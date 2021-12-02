%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% TRANSMATS.M: Generate transformation matrix and vector (T and A) from linear
%				constraint Rb=r.
%
% Matthew Gentzkow
% August, 2008
%
% note: a*b*c in dimension means vectors stacked as a groups of b groups of c
%
% INPUTS:
%	R		zz x pp             matrix of linear restrictions
%	r		zz                  vector of linear restrictions (Rb=r)
%	
% OUTPUTS:
%	T			pp x (pp-zz)		constraint matrix
%	A			pp					constraint vector
%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [T,A] = transmats(R,r)

pp = size(R,2);
zz = size(R,1);

if size(r) ~= zz
    error('Size of constraint vector does not match constraint matrix');
end

 Pmat = eye(pp)-R'*inv(R*R')*R;
 T = orth(Pmat);
 L = null(Pmat);
 A = r'*inv(L'*R')*L';

% test transmats
tolerance = 10^(-12);
b0 = randn(1,pp);
bc = b0*T;
b1 = bc*T'+A;
bc = b1*T;
b2 = bc*T'+A;
if max(abs(b2-b1))>tolerance
    error('Error in transmats');
end

A = A';