function out = rosPoseMsg2RBT(msg)
% ROSORIENTMSG2ARRAY converts a ROS Pose message to 4x4 Rigid Body
% Transform
%   out = rosOrientMsg2Array(msg)
%
%   Input(s)
%       msg - ROS Pose message
%
%   Output(s)
%       out - 4x4 element array containing position & orientation data
%
%   M. Kutzer & H. Helmich (reluctantly), 30Aug2022, USNA

%% Check inputs
narginchk(1,1)

goodClass = 'ros.msggen.geometry_msgs.PoseStamped';
switch lower( class(msg) )
    case lower( goodClass )
        % Good message
    otherwise
        badClass = class(msg); 
        error('Input message is class "%s", expected class "%s".',...
            badClass, goodClass);
end

%% Parse data
out = eye(4);
out(4,:) = [0 0 0 1];
out(1:3, 1:3) = rosOrientMsg2SO(msg.Pose.Orientation);
out(1:3, 4) = rosPointMsg2Array(msg.Pose.Position);
