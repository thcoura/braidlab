function [linv,Q] = find_reducing_curves(b)

import braidlab.*

badbraid = false;
if nargin < 1
  % The bad reducible braid.
  badbraid = true;
  b = braid([-3  1 -4  2 -3 -1 -2  3 -2  4  3  4]);
  lred = loop([0 -1 0 0 0 0 0 1]);
end

n = b.n;

tn = tntype(b);
fprintf('braid is %s.\n',tn)

[M,period] = b.cyclemat('iter');

Q = [];

for i = 1:period
  M{i} = full(M{i});

  if badbraid
    lred2 = b*lred;
    if all(lred2 == lred)
      fprintf('\nBad news... b*l == l, ');
    else
      fprintf('b*l ~= l, ');
    end
    if any(M{i}*lred.coords' ~= lred.coords')
      fprintf('M{%d}*l ~= l\n\n',i);
    end
    fprintf('     l = %s\n',num2str(lred.coords))
    fprintf('   b*l = %s\n',num2str(lred2.coords))
    fprintf('M{%d}*l = %s\n\n',i,num2str((M{i}*lred.coords')'))
    error('Invariant curve is not an eigenvector.')
  end

  % Get rid of "boundary" Dynnikov coordinates, a_(n-1) and b_(n-1).
  % If we don't do this there is an extra reducing curve around the
  % first n punctures.
  ii = [(1:n-2) (1:n-2)+n-2+1];
  M{i} = M{i}(ii,ii);

  A = M{i} - eye(size(M{i}));
  [U,D,V] = snf(A);  % Smith form of A.

  % Check that everything is ok.
  checksnf(A,U,D,V);

  D = diag(D);

  Qit{i} = round(inv(V))';
  Qit{i} = Qit{i}(:,find(D == 0));

  if rank(Qit{i}) < size(Qit{i},2)
    error('Qit{%d} doesn''t have full rank.',i)
  end

  % Make sure first nonzero component is positive.
  for j = 1:size(Qit{i},2)
    inz = find(Qit{i}(:,j) ~= 0);
    if Qit{i}(inz(1),j) < 0
      Qit{i}(:,j) = -Qit{i}(:,j);
    end
  end

  % Take the intersection of the coordinates, since a loop must be
  % invariant for each iterate.
  if isempty(Q)
    Q = Qit{i};
  else
    Q = intersect(Q',Qit{i}','rows')';
  end

  % If the nullspace is empty, it cannot be reducible.
  if isempty(Q)
    Q = [];
    linv = [];
    return
  end
end

% If Q has rank one, easy to check if it's an invariant loop.
if size(Q,2) == 1

  linv = loop(Q);
  if b*linv == linv
    return
  end

  linv = loop(-Q);
  if b*linv == linv
    return
  end

  Q = [];
  linv = [];
  return
end

% Now cycle over linear combinations of the columns of Q.

mm = size(Q,2);

doplot = false;
if doplot
  close all
  figure
  for i = 1:mm
    subplot(mm,1,i)
    plot(loop(Q(:,i)))
  end
end

N = 3;  % Go from -N to N in each component.
%nwords = (2*N+1)^mm;

Z = -N*ones(mm,1); Z(end) = -N-1;

linv = [];

while 1
  incr = false;
  % Do not change the first generator (leave at 1).
  for w = mm:-1:1
    if Z(w) < N
      incr = true;
      % Increment the generator.
      Z(w) = Z(w)+1;
      break
    else
      % Otherwise reset generator at that position, and let the
      % loop move on to the next position.
      Z(w) = -N;
    end
  end

  % If nothing was changed, we're done.
  if ~incr, break; end

  l = loop(Q*Z);
  if b*l == l
    if ~all(l.coords == 0) && ~nested(l)
      linv = [linv ; l];
    end
  end

  %if w == 2, disp(num2str(Z')); end
end

if ~strcmp(tn,'reducible') && ~isempty(linv)
  error('Braid is not reducible, yet we found a reducing curve.')
end

if strcmp(tn,'reducible') && isempty(linv)
  % Example: < -3  1 -4  2 -3 -1 -2  3 -2  4  3  4 >  Why?
  warning('Braid is reducible, but we didn''t find a reducing curve.')
end