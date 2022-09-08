function out = rosOrientMsg2SO(msg)
% ROSORIENTMSG2ARRAY converts a ROS Point message to an array
%   out = rosOrientMsg2Array(msg)
%
%   Input(s)
%       msg - ROS Quaternion message
%
%   Output(s)
%       out - 3-element array containing x/y/z data
%
%   M. Kutzer & H. Helmich (reluctantly), 30Aug2022, USNA

%% Check inputs
narginchk(1,1)

goodClass = 'ros.msg.geometry_msgs.Quaternion';
switch lower( class(msg) )
    case lower( goodClass )
        % Good message
    otherwise
        badClass = class(msg); 
        error('Input message is class "%s", expected class "%s".',...
            badClass, goodClass);
end

%% Parse data

X = msg.X;
Y = msg.Y;
Z = msg.Z;
W = msg.W;

out = quat2rotm([X Y Z W]);

% % First row
% out(1,1) = 2 * (X*X + Y*Y) - 1;
% out(1,2) = 2 * (Y*Z + X*W);
% out(1,3) = 2 * (Y*W + X*Z);
% % Second row
% out(2,1) = 2 * (Y*Z + X*W);
% out(2,2) = 2 * (X*X + Z*Z) - 1;
% out(2,3) = 2 * (Z*W - X*Y);
% % Third row
% out(3,1) = 2 * (Y*W - X*Z);
% out(3,2) = 2 * (Z*W - X*Y);
% out(3,3) = 2 * (X*X + W*W) - 1;


end