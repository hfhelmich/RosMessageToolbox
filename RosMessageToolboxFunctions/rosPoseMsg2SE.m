function out = rosPoseMsg2SE(msg)
% ROSPOSEMSG2SE converts a ROS Pose message to 4x4 Rigid Body
% Transform. A message "m" from a pose subscriber returns PoseStamped. If a
% user inputs a subsection of that message, there is no way to go back.
% Message input must be of the correct class. See below.
%
%   Input(s)
%       msg - ROS PoseStamped message
%
%   Output(s)
%       out - 4x4 element array containing position & orientation data
%
%   M. Kutzer & H. Helmich, 30Aug2022, USNA

% Check inputs
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
% Parse data
out = eye(4);
out(4,:) = [0 0 0 1];
quat = rosOrientMsg2SO(msg.Pose.Orientation);
out(1:3, 1:3) = quat2rotm(quat');
out(1:3, 4) = rosPointMsg2Array(msg.Pose.Position);