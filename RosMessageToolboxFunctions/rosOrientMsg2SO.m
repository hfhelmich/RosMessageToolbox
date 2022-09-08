function quat = rosOrientMsg2SO(msg)
% ROSORIENTMSG2SO converts a ROS Orient message to an array. A message "m"
% from a pose subscriber returns PoseStamped.
%   - m.Pose is a Pose message
%   - m.Pose.Orientation is a Point message
%
%   Input(s)
%       msg - ROS message containing Quaternion data
%
%   Output(s)
%       out - 3x3 -element array containing rotation [W X Y Z] data
%
%   M. Kutzer & H. Helmich, 30Aug2022, USNA

%   Updates
%       8Sep22 - added 2 cases to auto adjust in case user inputs incorrect
%       message type. If the message type is way off (i.e. not even a pose
%       message to begin with, then an error will be thrown).

% Check inputs
narginchk(1,1)

goodClass = 'ros.msg.geometry_msgs.Quaternion';
switch lower( class(msg) )
    case lower( goodClass )
        % Good message
    case lower( 'ros.msggen.geometry_msgs.PoseStamped' )
        % User inputted an untouched message. Adjust.
        msg = msg.Pose.Orientation;
    case lower( 'ros.msggen.geometry_msgs.Pose' )
        % User inputted a message one level too high. Adjust.
        msg = msg.Orientation;
    otherwise
        badClass = class(msg);
        error('Input message is class "%s", expected class "%s".',...
            badClass, goodClass);
end

% Parse data
X = msg.X;
Y = msg.Y;
Z = msg.Z;
W = msg.W;

% Notice the order of vars below. See quat2rotm documentation.
quat = [W; X; Y; Z];