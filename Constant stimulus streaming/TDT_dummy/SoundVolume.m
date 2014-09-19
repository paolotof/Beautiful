function values = SoundVolume(varargin)

%SOUNDVOLUME()
%
%   S = SOUNDVOLUME() returns a structure containing the details of the
%   different sound controls available.
%
%   SOUNDVOLUME('volume', VALUE, ...) will set the different controls to
%   the specified VALUE. A structure like the one returned by the function
%   can also be passed as single argument.
%
%   SOUNDVOLUME('max') will set the master volume and the wave volume to
%   maximum and mute the other lines.
%
%   S = SOUNDVOLUME(...) returns the structure containing the values before
%   modification. After changing the volume just call SOUNDVOLUME(S) to
%   restore the initial values.

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Based on http://undocumentedmatlab.com/blog/updating-speaker-sound-volume/
% by Yair Altman.
%-----------------------------------------------
% Etienne Gaudrain - 2011-11-11
% MRC Cognition and Brain Sciences Unit, Cambridge, UK
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

debug = true;

% Loop over the system's mixers to find the speaker port
import javax.sound.sampled.*
mixerInfos = AudioSystem.getMixerInfo;
foundFlag = 0;
for mixerIdx = 1 : length(mixerInfos)
    if debug
        fprintf('Scanning %s...\n', char(mixerInfos(mixerIdx)));
    end
    mixer = AudioSystem.getMixer(mixerInfos(mixerIdx));
    ports = getTargetLineInfo(mixer);
    for portIdx = 1 : length(ports)
        port = ports(portIdx);
        try
            portName = port.getName;  % better
        catch   %#ok
            portName = port.toString; % sub-optimal
        end
        if debug
            fprintf('    Found %s\n', char(portName));
        end
        if ~isempty(strfind(lower(char(portName)),'speaker'))
            foundFlag = 1;
            break;
        end
    end
end
if ~foundFlag
	error('Speaker port not found');
end

% Get and open the speaker port's Line object
line = AudioSystem.getLine(port);
line.open();

% Loop over the Line's controls to find the Volume control
ctrls = line.getControls;
controls = struct();
control_names = {'volume', 'wave', 'cd player', 'mute', 'microphone', 'input', 'balance'};
for ctrlIdx = 1 : length(ctrls)
    ctrl = ctrls(ctrlIdx);
    ctrlName = char(ctrls(ctrlIdx).getType());
    for i=1:length(control_names)
        control_name = control_names{i};
        field = strrep(control_name, ' ', '_');
        if ~isfield(controls, field) && ~isempty(strfind(lower(ctrlName), control_name))
            if ismethod(ctrl, 'getMemberControls')
                mCtrls = ctrl.getMemberControls();
                for j=1:length(mCtrls)
                    mCtrl = mCtrls(j);
                    mCtrlName = lower(char(mCtrl.getType()));
                    switch mCtrlName
                        case {'volume', 'mute', 'balance'}
                            controls.([field, '_', mCtrlName]) = mCtrl;
                    end
                end
            else
                controls.(field) = ctrl;
            end
        end
    end
    if length(fieldnames(controls))==length(control_names)
        break;
    end
end
if ~isfield(controls, 'volume')
  error('Volume control not found');
end

% Get the volume values
control_names = fieldnames(controls);
if nargout
    values = struct();
    for i=1:length(control_names)
        values.(control_names{i}) = controls.(control_names{i}).getValue();
    end
end

% Set the volume value according to the user request

if ~isempty(varargin)
    if length(varargin)==1
        if ischar(varargin{1})
            switch lower(varargin{1})
                case 'max'
                    for i=1:length(control_names)
                        switch control_names{i}
                            case {'volume', 'wave_volume', 'cd_player_mute', 'microphone_mute', 'input_mute'}
                                controls.(control_names{i}).setValue(1);
                            case {'mute', 'wave_mute', 'balance', 'wave_balance'}
                                controls.(control_names{i}).setValue(0);
                        end
                    end
            end
        elseif isstruct(varargin{1})
            arg = varargin{1};
            argfields = fieldnames(arg);
            for i=1:length(argfields)
                if isfield(controls, argfields{i})
                    controls.(argfields{i}).setValue( arg.(argfields{i}) );
                else
                    warning(sprintf('Control "%s" was not found and will not be set.', argfields{i}));
                end
            end
        end
    elseif mod(length(varargin), 2)==0
        for i=1:length(varargin)/2
            if ischar(varargin{2*i-1}) && isnumeric(varargin{2*i})
                if isfield(controls, varargin{2*i-1})
                    controls.(varargin{2*i-1}).setValue( varargin{2*i} );
                else
                    warning(sprintf('Control "%s" was not found and will not be set.', varargin{2*i-1}));
                end 
            else
                error(sprintf('Argument %d or %d is not in the right format.', 2*i-1, 2*i));
            end
        end
    else
        error('Argument list not understood...');
    end
end

   
      