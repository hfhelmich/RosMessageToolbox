function installRosMessageToolbox(replaceExisting)
% INSTALLROSMESSAGETOOLBOX installs RosMessageToolbox for MATLAB.
%   INSTALLROSMESSAGETOOLBOX installs RosMessageToolbox into the following 
%   locations:
%                             Source: Destination
%           RosMessageToolboxFunctions: matlabroot\toolbox\rosmessage
%
%   INSTALLROSMESSAGETOOLBOX(true) installs RosMessageToolbox regardless of
%   whether a copy of the RosMessageToolbox exists in the MATLAB root.
%
%   INSTALLROSMESSAGETOOLBOX(false) installs RosMessageToolbox only if no copy 
%   of the RosMessageToolbox exists in the MATLAB root.
%
%   M. Kutzer, 09Sep2022, USNA

% Updates

%% Define toolbox name
toolboxName = 'RosMessageToolbox';

%% Define support toolboxes 
% This has been updated syntax for multiple github user support
%   supportToolboxes{i,1} - github username for ith support toolbox
%   supportToolboxes{i,2} - toolbox name [toolbox name]Toolbox
supportToolboxes = {};

%% Assign tool/toolbox specific parameters
idx = strfind( lower(toolboxName),'toolbox');
if ~isempty(idx)
    dirName = lower( toolboxName(1:(idx-1)) );
else
    error('toolboxName must be specified as *Toolbox');
end

%% Check inputs
if nargin == 0
    replaceExisting = [];
end

%% Installation error solution(s)
adminSolution = sprintf(...
    ['Possible solution:\n',...
     '\t(1) Close current instance of MATLAB\n',...
     '\t(2) Open a new instance of MATLAB "as administrator"\n',...
     '\t\t(a) Locate MATLAB shortcut\n',...
     '\t\t(b) Right click\n',...
     '\t\t(c) Select "Run as administrator"\n']);

%% Check for toolbox directory
toolboxRoot  = fullfile(matlabroot,'toolbox',dirName);
isToolbox = exist(toolboxRoot,'file');
if isToolbox == 7
    % Apply replaceExisting argument
    if isempty(replaceExisting)
        choice = questdlg(sprintf(...
            ['MATLAB Root already contains the %s.\n',...
            'Would you like to replace the existing toolbox?'],toolboxName),...
            springt('Replace Existing %s',toolboxName),...
            'Yes','No','Cancel','Yes');
    elseif replaceExisting
        choice = 'Yes';
    else
        choice = 'No';
    end
    % Replace existing or cancel installation
    switch choice
        case 'Yes'
            rmpath(toolboxRoot);
            [isRemoved, msg, msgID] = rmdir(toolboxRoot,'s');
            if isRemoved
                fprintf('Previous version of %s removed successfully.\n',toolboxName);
            else
                fprintf('Failed to remove old %s folder:\n\t"%s"\n',toolboxName,toolboxRoot);
                fprintf(adminSolution);
                error(msgID,msg);
            end
        case 'No'
            fprintf('%s currently exists, installation cancelled.\n',toolboxName);
            return
        case 'Cancel'
            fprintf('Action cancelled.\n');
            return
        otherwise
            error('Unexpected response.');
    end
end

%% Create RosMessageToolbox Path
[isDir,msg,msgID] = mkdir(toolboxRoot);
if isDir
    fprintf('%s folder created successfully:\n\t"%s"\n',toolboxName,toolboxRoot);
else
    fprintf('Failed to create %s folder:\n\t"%s"\n',toolboxName,toolboxRoot);
    fprintf(adminSolution);
    error(msgID,msg);
end

%% Migrate toolbox folder contents
toolboxContent = sprintf('%sFunctions',toolboxName);
if ~isfolder(toolboxContent)
    error(sprintf(...
        ['Change your working directory to the location of "install%s.m".\n',...
         '\n',...
         'If this problem persists:\n',...
         '\t(1) Unzip your original download of "%s" into a new directory\n',...
         '\t(2) Open a new instance of MATLAB "as administrator"\n',...
         '\t\t(a) Locate MATLAB shortcut\n',...
         '\t\t(b) Right click\n',...
         '\t\t(c) Select "Run as administrator"\n',...
         '\t(3) Change your "working directory" to the location of "install%s.m"\n',...
         '\t(4) Enter "install%s" (without quotes) into the command window\n',...
         '\t(5) Press Enter.'],toolboxName,toolboxName,toolboxName,toolboxName));
end
files = dir(toolboxContent);
wb = waitbar(0,sprintf('Copying %s contents...',toolboxName));
n = numel(files);
fprintf('Copying %s contents:\n',toolboxName);
for i = 1:n
    % source file location
    source = fullfile(toolboxContent,files(i).name);
    % destination location
    destination = toolboxRoot;
    if files(i).isdir
        switch files(i).name
            case '.'
                %Ignore
            case '..'
                %Ignore
            otherwise
                fprintf('\t%s...',files(i).name);
                nDestination = fullfile(destination,files(i).name);
                [isDir,msg,msgID] = mkdir(nDestination);
                if isDir
                    [isCopy,msg,msgID] = copyfile(source,nDestination,'f');
                    if isCopy
                        fprintf('[Complete]\n');
                    else
                        bin = msg == char(10);
                        msg(bin) = [];
                        bin = msg == char(13);
                        msg(bin) = [];
                        fprintf('[Failed: "%s"]\n',msg);
                    end
                else
                    bin = msg == char(10);
                    msg(bin) = [];
                    bin = msg == char(13);
                    msg(bin) = [];
                    fprintf('[Failed: "%s"]\n',msg);
                end
        end
    else
        fprintf('\t%s...',files(i).name);
        [isCopy,msg,msgID] = copyfile(source,destination,'f');
        
        if isCopy == 1
            fprintf('[Complete]\n');
        else
            bin = msg == char(10);
            msg(bin) = [];
            bin = msg == char(13);
            msg(bin) = [];
            fprintf('[Failed: "%s"]\n',msg);
        end
    end
    waitbar(i/n,wb);
end
set(wb,'Visible','off');

%% Save toolbox path
%addpath(genpath(toolboxRoot),'-end');
addpath(toolboxRoot,'-end');
savepath;

%% Rehash toolbox cache
fprintf('Rehashing Toolbox Cache...');
rehash TOOLBOXCACHE
fprintf('[Complete]\n');

%% Install/Update required toolboxes
for i = 1:size(supportToolboxes,1)
    ToolboxUpdate( supportToolboxes(i,:) );
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TOOLBOX UPDATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 08Sep2022 - Updated for github username and toolbox name input
function ToolboxUpdate(toolboxName)

%% Parse input
switch numel(toolboxName)
    case 1
        % Legacy input
        gitUsername = 'kutzer';
        toolboxName = toolboxName{1};
    case 2
        % Git username and toolbox name input
        gitUsername = toolboxName{1};
        toolboxName = toolboxName{2};
    otherwise
        error('Expected input must be a 1 or 2 element cell array.');
end

%% Setup functions
ToolboxVer     = str2func( sprintf('%sToolboxVer',toolboxName) );
installToolbox = str2func( sprintf('install%sToolbox',toolboxName) );

%% Check current version
try
    A = ToolboxVer;
catch ME
    A = [];
    fprintf('No previous version of %s detected.\n',toolboxName);
end

%% Setup temporary file directory
% TODO - check "ok"
fprintf('Creating %s Toolbox temporary directory...',toolboxName);
tmpFolder = sprintf('%sToolbox',toolboxName);
pname = fullfile(tempdir,tmpFolder);
if isfolder(pname)
    % Remove existing directory
    [ok,msg] = rmdir(pname,'s');
end
% Create new directory
[ok,msg] = mkdir(tempdir,tmpFolder);
fprintf('SUCCESS\n');


%% Download and unzip toolbox (GitHub)
% UPDATED: 07Sep2021, M. Kutzer
%url = sprintf('https://github.com/%s/%sToolbox/archive/refs/heads/master.zip',gitUsername,toolboxName); <--- Github removed references to "master"
%url = sprintf('https://github.com/%s/%sToolbox/archive/refs/heads/main.zip'  ,gitUsername,toolboxName);

% Check possible branches
defBranches = {'master','main'};
for i = 1:numel(defBranches)
    % Check default branch
    defBranch = defBranches{i};
    url = sprintf('https://github.com/%s/%sToolbox/archive/refs/heads/%s.zip',...
        gitUsername,toolboxName,defBranch);
    
    % Download and unzip repository
    fprintf('Downloading the %s Toolbox ("%s" branch)...',toolboxName,defBranch);
    try
        %fnames = unzip(url,pname);
        %urlwrite(url,fullfile(pname,tmpFname));
        tmpFname = sprintf('%sToolbox-master.zip',toolboxName);
        websave(fullfile(pname,tmpFname),url);
        fnames = unzip(fullfile(pname,tmpFname),pname);
        delete(fullfile(pname,tmpFname));
        
        fprintf('SUCCESS\n');
        confirm = true;
        break
    catch ME
        fprintf('"%s" branch does not exist\n',defBranch);
        confirm = false;
        %fprintf(2,'ERROR MESSAGE:\n\t%s\n',ME.message);
    end
end

%% Check for successful download
alternativeInstallMsg = [...
    sprintf('Manually download the %s Toolbox using the following link:\n',toolboxName),...
    newline,...
    sprintf('%s\n',url),...
    newline,...
    sprintf('Once the file is downloaded:\n'),...
    sprintf('\t(1) Unzip your download of the "%sToolbox"\n',toolboxName),...
    sprintf('\t(2) Change your "working directory" to the location of "install%sToolbox.m"\n',toolboxName),...
    sprintf('\t(3) Enter "install%sToolbox" (without quotes) into the command window\n',toolboxName),...
    sprintf('\t(4) Press Enter.')];

if ~confirm
    warning('InstallToolbox:FailedDownload','Failed to download updated version of %s Toolbox.',toolboxName);
    fprintf(2,'\n%s\n',alternativeInstallMsg);
    
    msgbox(alternativeInstallMsg, sprintf('Failed to download %s Toolbox',toolboxName),'warn');
    return
end

%% Find base directory
install_pos = strfind(fnames, sprintf('install%sToolbox.m',toolboxName) );
sIdx = cell2mat( install_pos );
cIdx = ~cell2mat( cellfun(@isempty,install_pos,'UniformOutput',0) );

pname_star = fnames{cIdx}(1:sIdx-1);

%% Get current directory and temporarily change path
cpath = cd;
cd(pname_star);

%% Install Toolbox
installToolbox(true);

%% Move back to current directory and remove temp file
cd(cpath);
[ok,msg] = rmdir(pname,'s');
if ~ok
    warning('Unable to remove temporary download folder. %s',msg);
end

%% Complete installation
fprintf('Installation complete.\n');

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% END TOOLBOX UPDATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%