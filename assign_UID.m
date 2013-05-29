function [epics_UID, image_UID, aida_UID] = assign_UID(EPICS_PID,EPICS_SCANSTEP,EPICS_DATASET,IMAGE_PID,IMAGE_SCANSTEP,AIDA_PID,AIDA_SCANSTEP)
% function [epics_UID, image_UID, aida_UID] =
%   assign_UID(EPICS_PID,EPICS_SCANSTEP,EPICS_DATASET,...
%   IMAGE_PID,IMAGE_SCANSTEP,AIDA_PID,AIDA_SCANSTEP)
%
% Inputs:
%   EPICS_PID:      Vector of pulse IDs from PATT_SYS1_1_PULSEID
%   EPICS_SCANSTEP: Vector of scan steps
%   EPICS_DATASET:  Vector of dataset
%   IMAGE_PID:      Vector of pulse IDs from E200_readImages
%   IMAGE_SCANSTEP: Vector of scan steps
%   AIDA_PID:       Vector of pulse IDs from AIDA struct
%   AIDA_SCANSTEP:  Vector of scan steps
%
% Outputs:
%   epics_UID:      Vector of unique IDs as long as EPICS_PID
%   image_UID:      Vector of unique IDs as long as IMAGE_PID
%   aida_UID:       Vector of unique IDs as long as AIDA_PID
%
% Enumerate EPICS shots in steps in datasets and create a 
% unique ID (UID). Assign UID to image and AIDA data.


% EPICS_SHOT is the index of the shot in the step in the dataset
step = unique(EPICS_SCANSTEP);
EPICS_SHOT = [];
for i = 1:length(step)
    EPICS_SHOT = [EPICS_SHOT; (1:sum(EPICS_SCANSTEP == step(i)))'];
end
% Create UID from dataset, scan step, and shot number
epics_UID = 1e6*EPICS_DATASET+1e4*EPICS_SCANSTEP+EPICS_SHOT;


% Assign UID to image data
if nargin > 4
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
            [~,~,ib] = intersect(IPID,EPID);
        else                                    % not monotonic
            if ~isempty(k)
                iid_lo = IPID(1:k);
                iid_hi = IPID((k+1):end);
            else
                iid_lo = [];
                iid_hi = IPID;
            end
            [~,~,ib_lo] = intersect(iid_lo,EPID);
            [~,~,ib_hi] = intersect(iid_hi,EPID);
            ib = [ib_lo; ib_hi];
        end        
        % assign image UID
        image_UID = [image_UID; EUID(ib)];
    end    
end


% Assign UID to aida data
if nargin == 7
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
            [~,~,ab] = intersect(APID,EPID);
        else                                    % not monotonic
            if ~isempty(k)
                aid_lo = APID(1:k);
                aid_hi = APID((k+1):end);
            else
                aid_lo = [];
                aid_hi = APID;
                k = 0;
            end
            [~,~,ab_lo] = intersect(aid_lo,EPID);
            [~,~,ab_hi] = intersect(aid_hi,EPID);
            ab = [ab_lo; ab_hi+k];
        end        
        % assign image UID
        aida_UID = [aida_UID; EUID(ab)];
    end 
end
