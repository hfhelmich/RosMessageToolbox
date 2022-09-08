function out = rosPointMsg2Array(msg)
% ROSPOINTMSG2ARRAY converts a ROS Point message to an array. A message "m"
% from a pose subscriber returns PoseStamped.
%   - m.Pose is a Pose message
%   - m.Pose.Position is a Point message
%
%   Input(s)
%       msg - ROS message containing Position data
%
%   Output(s)
%       out - 3-element array containing x/y/z data
%
%   M. Kutzer & H. Helmich, 30Aug2022, USNA

%   Updates
%       8Sep22 - added 2 cases to auto adjust in case user inputs incorrect
%       message type. If the message type is way off (i.e. not even a pose
%       message to begin with, then an error will be thrown).

% Check inputs
narginchk(1,1)

goodClass = 'ros.msggen.geometry_msgs.Point';
switch lower( class(msg) )
    case lower( goodClass )
        % Good message
    case lower( 'ros.msggen.geometry_msgs.PoseStamped' )
        % User inputted an untouched message. Adjust.
        msg = msg.Pose.Position;
    case lower( 'ros.msggen.geometry_msgs.Pose' )
        % User inputted a message one level too high. Adjust.
        msg = msg.Position;
    otherwise
        badClass = class(msg);
        error('Input message is class "%s", expected class "%s".',...
            badClass, goodClass);
end

% Parse data
out(1,1) = msg.X;
out(2,1) = msg.Y;
out(3,1) = msg.Z;