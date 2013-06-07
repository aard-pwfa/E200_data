function out = assign_UID(EPICS_PID,EPICS_SCANSTEP,EPICS_DATASET,varargin)
% IMAGE_PID,IMAGE_SCANSTEP,AIDA_PID,AIDA_SCANSTEP)
% function [epics_UID, image_UID, aida_UID] =
%   assign_UID(EPICS_PID,EPICS_SCANSTEP,EPICS_DATASET,optional_struct
%   IMAGE_PID,IMAGE_SCANSTEP,AIDA_PID,AIDA_SCANSTEP)
%
% Inputs:
%   EPICS_PID:		Vector of pulse IDs from PATT_SYS1_1_PULSEID			(required)
%   EPICS_SCANSTEP:	Vector of scan steps						(required)
%   EPICS_DATASET:  	Vector of dataset						(required)
%   optional_struct:	Struct containing the following optional fields:		(optional)
%   	optional_struct.IMAGE_PID:      Vector of pulse IDs from E200_readImages	(optional)
%   	optional_struct.IMAGE_SCANSTEP: Vector of scan steps				(optional)
%   	optional_struct.AIDA_PID:       Vector of pulse IDs from AIDA struct		(optional)
%   	optional_struct.AIDA_SCANSTEP:  Vector of scan steps				(optional)
%
% Outputs:
%   epics_UID:      Vector of unique IDs as long as EPICS_PID
%   image_UID:      Vector of unique IDs as long as IMAGE_PID
%   aida_UID:       Vector of unique IDs as long as AIDA_PID
%
% Enumerate EPICS shots in steps in datasets and create a 
% unique ID (UID). Assign UID to image and AIDA data.

% Deconstruct optional_struct into variables
if nargin==4
	optional_struct=varargin{1};
	str=fieldnames(optional_struct);
	for i=1:size(str,1)
		eval([str{i} '= optional_struct.' str{i} ';']);
	end
end

% EPICS_SHOT is the index of the shot in the step in the dataset
step = unique(EPICS_SCANSTEP);
EPICS_SHOT = [];
for i = 1:length(step)
    EPICS_SHOT = [EPICS_SHOT; (1:sum(EPICS_SCANSTEP == step(i)))'];
end
% Create UID from dataset, scan step, and shot number
epics_UID = 1e8*EPICS_DATASET+1e4*EPICS_SCANSTEP+EPICS_SHOT';
out.epics_UID=epics_UID;

% Assign UID to image data
if exist('IMAGE_PID')
    image_UID = [];
    for i = 1:length(step)       
        % isolate pulse IDs for relevant scan step
        EPID = EPICS_PID(EPICS_SCANSTEP == step(i));
        EUID = epics_UID(EPICS_SCANSTEP == step(i));
        IPID = IMAGE_PID(IMAGE_SCANSTEP == step(i));        
        % determine if pulse IDs return to zero during scan step
        e_lo = EPID(1:(end-1));
        e_hi = EPID(2:end);
        i_lo = IPID(1:(end-1));
        i_hi = IPID(2:end);
        j = find(e_hi < e_lo,1,'first');
        k = find(i_hi < i_lo,1,'first');        
        % find image pulse IDs in EPICS pulse ID vector
        if isempty(j) && isempty(k)             % monotonic
            [discard,discard,ib] = intersect(IPID,EPID);
        else                                    % not monotonic
            if ~isempty(k)
                iid_lo = IPID(1:k);
                iid_hi = IPID((k+1):end);
            else
                iid_lo = [];
                iid_hi = IPID;
            end
            [discard,discard,ib_lo] = intersect(iid_lo,EPID);
            [discard,discard,ib_hi] = intersect(iid_hi,EPID);
            ib = [ib_lo', ib_hi'];
        end        
        % assign image UID
        image_UID = [image_UID; EUID(ib)];
    end
    out.image_UID=image_UID;
end


% Assign UID to aida data
if exist('AIDA_PID')
    aida_UID = [];
    for i = 1:length(step)        
        % isolate pulse IDs for relevant scan step
        EPID = EPICS_PID(EPICS_SCANSTEP == step(i));
        EUID = epics_UID(EPICS_SCANSTEP == step(i));
        APID = AIDA_PID(AIDA_SCANSTEP == step(i));        
        % determine if pulse IDs return to zero during scan step
        e_lo = EPID(1:(end-1));
        e_hi = EPID(2:end);
        a_lo = APID(1:(end-1));
        a_hi = APID(2:end);
        j = find(e_hi < e_lo,1,'first');
        k = find(a_hi < a_lo,1,'first');       
        % find aida pulse IDs in EPICS pulse ID vector
        if isempty(j) && isempty(k)             % monotonic
            [discard,discard,ab] = intersect(APID,EPID);
        else                                    % not monotonic
            if ~isempty(k)
                aid_lo = APID(1:k);
                aid_hi = APID((k+1):end);
            else
                aid_lo = [];
                aid_hi = APID;
                k = 0;
            end
            [discard,discard,ab_lo] = intersect(aid_lo,EPID);
            [discard,discard,ab_hi] = intersect(aid_hi,EPID);
            ab = [ab_lo; ab_hi+k];
        end        
        % assign image UID
        aida_UID = [aida_UID; EUID(ab)];
    end 
    out.aida_UID=aida_UID;
end
