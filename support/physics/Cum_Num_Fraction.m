function F = Cum_Num_Fraction(m)
% This function calculates the cumulated number fraction of the mass
% distribution.

a = .9;
b = .26 / a;
c = 2;
mt = 1e-13;
x = (m ./ mt).^(1/c);

F = ( (1+x).^(b-1) ./ (x.^b) ).^(a*c);

end

