function c = flatFilter(a)
% Flat filter function 
% Chris Eckman, SLAC, 2013
%
% input:  a = region to be filtered [logical matrix]
% output: c = filtered region       [logical matrix]

[m n] = size(a) ;
N = numel(a);
k = reshape (1:N, m, n);
west  = [(k(:,2:n).*(a(:,1:n-1) == a(:,2:n))) zeros(m,1)];
south = [(k(2:m,:).*(a(1:m-1,:) == a(2:m,:))); zeros(1,n)];
W = find(west);
S = find(south);
A = sparse([k(W);k(S);(1:N)'], [west(W);south(S);(1:N)'], [a(W);a(S);(1:N)'], N, N);
[p q r s] = dmperm (A+A');
[siz b] = max(diff(r));
c = false(m,n) ;
c(p([r(b):r(b+1)-1])) = true;