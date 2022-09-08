function out = rosPointMsg2Array(msg)
% ROSPOINTMSG2ARRAY converts a ROS Point message to an array
%   out = rosPointMsg2Array(msg)
%
%   Input(s)
%       msg - ROS Point message
%
%   Output(s)
%       out - 3-element array containing x/y/z data
%
%   M. Kutzer & H. Helmich (reluctantly), 30Aug2022, USNA

%% Check inputs
narginchk(1,1)

goodClass = 'ros.msggen.geometry_msgs.Point';
switch lower( class(msg) )
    case lower( goodClass )
        % Good message
    otherwise
        badClass = class(msg); 
        error('Input message is class "%s", expected class "%s".',...
            badClass,goodClass);
end

%% Parse data
out(1,1) = msg.X;
out(2,1) = msg.Y;
out(3,1) = msg.Z;

end