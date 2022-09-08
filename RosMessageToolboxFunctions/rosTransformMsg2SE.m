function out = rosTransformMsg2SE(msg)
% ROSTRANSFORMMSG2SE converts a ROS Transform message to a 4x4 Rigid Body.
% Transform messages come from the /tf topic. If multiple systems are
% running in the viper lab, then there will be multiple publishers to this
% topic, which will result in multiple Transforms in a single message. This
% is being fixed but for now, this method will give users all transforms
% being received. Ideally, the user wants to have only one transform being
% sent to them.
%
%   Harrison Helmich, 8Sep22, USNA

narginchk(1,1);
n = numel(msg.Transforms);

if n > 1
    for i = 1:n
        msg = msg.Transforms.Transform;
        pos = rosPointMsg2Array(msg);   % 3x1
        rot = rosOrientMsg2SO(msg);     % 3x3

        out{i}(1:3, 4) = pos;
        out{i}(1:3, 1:3) = rot;
        out{i}(4, 1:4) = [0 0 0 1];
    end
elseif n == 1
    msg = msg.Transforms.Transform;
    pos = rosPointMsg2Array(msg);   % 3x1
    rot = rosOrientMsg2SO(msg);     % 3x3

    out(1:3, 4) = pos;
    out(1:3, 1:3) = rot;
    out(4, 1:4) = [0 0 0 1];
else
    error("No transforms were received.");
end