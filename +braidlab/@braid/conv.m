function val = conv(varargin)
%CONV   Get and set conventions for braids.
%   braid.CONV('PropertyName',VALUE) assigns VALUE to a braid property.
%   This property is shared by all braid objects and need only be set once.
%
%   braid.CONV('PropertyName') returns the current value of the property.
%
%   Valid properties and values are (defaults in braces):
%
%   * RotDir - The direction of rotation of generators [ {1} | -1 ].  This
%   is the direction of rotation when strings are exchanged by generators.
%   A value of 1 corresponds to clockwise, -1 to counterclockwise.
%
%   This is a static method for the BRAID class.
%   See also BRAID, LOOP.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2015  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic         <marko@math.wisc.edu>
%
%   This file is part of Braidlab.
%
%   Braidlab is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   Braidlab is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with Braidlab.  If not, see <http://www.gnu.org/licenses/>.
% LICENSE>

import braidlab.util.validateflag

persistent rotdir

if isempty(rotdir), rotdir = 1; end

if nargin == 0
  % Maybe list all conventions?
  error('BRAIDLAB:braid:conv:badarg','Need at least one argument.')
end

if nargin == 1
  flag = lower(varargin{1});
  switch flag
   case {'rotdir'}
    val = rotdir;
   otherwise
    error('BRAIDLAB:braid:conv:badarg','Unknown string argument.')
  end
  return
end

parser = inputParser;
parser.addParameter('rotdir', 1, @(x) x == 1 || x == -1);
parser.parse(varargin{:});
params = parser.Results;

rotdir = params.rotdir;

val = rotdir;
