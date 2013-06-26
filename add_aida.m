function data = add_aida(data,aida_data,options)
% data = add_aida(data,aida_data,options)
% add_aida appends AIDA data to the E200 data file
%
% Inputs:
%       data:   E200 data structure
%  aida_data:   Raw aida_data structure
%    options:   Struct with additional information
%
% Outputs:
%	DATA:		E200 data structure

% Get number of shots in set
n_a_shots = length(aida_data);

% Get scan step
a_scan_step=ones(1,n_a_shots)*options.scan_step;

% Get pulse ID and assign UID
pulse_id = [aida_data.pulse_id];
option.AIDA_PID=pulse_id;
option.AIDA_SCANSTEP=a_scan_step;
EPICS_PID = data.raw.scalars.PATT_SYS1_1_PULSEID.dat;
EPICS_SCANSTEP = data.raw.scalars.step_num.dat;
EPICS_DATASET = data.raw.scalars.set_num.dat;
out = assign_UID(EPICS_PID,EPICS_SCANSTEP,EPICS_DATASET,option);

% allocate data arrays
n_bpms = length(aida_data(1).bpms);
n_toro = length(aida_data(1).toro);
n_klys = length(aida_data(1).klys);

BPMS_ARRAY = struct();
BPMS_ARRAY.name = cell(n_bpms,n_a_shots);
BPMS_ARRAY.x    = zeros(n_bpms,n_a_shots);
BPMS_ARRAY.y    = zeros(n_bpms,n_a_shots);
BPMS_ARRAY.z    = zeros(n_bpms,n_a_shots);
BPMS_ARRAY.tmit = zeros(n_bpms,n_a_shots);
BPMS_ARRAY.stat = zeros(n_bpms,n_a_shots);
BPMS_ARRAY.good = zeros(n_bpms,n_a_shots);

TORO_ARRAY = struct();
TORO_ARRAY.name = cell(n_toro,n_a_shots);
TORO_ARRAY.z    = zeros(n_toro,n_a_shots);
TORO_ARRAY.tmit = zeros(n_toro,n_a_shots);
TORO_ARRAY.stat = zeros(n_toro,n_a_shots);
TORO_ARRAY.good = zeros(n_toro,n_a_shots);

KLYS_ARRAY = struct();
KLYS_ARRAY.name = cell(n_klys,n_a_shots);
KLYS_ARRAY.z    = zeros(n_klys,n_a_shots);
KLYS_ARRAY.phas = zeros(n_klys,n_a_shots);
KLYS_ARRAY.stat = zeros(n_klys,n_a_shots);

% add data to structure
for i = 1:n_a_shots
    
    BPMS_ARRAY.name(:,i) = {aida_data(i).bpms.name};
    BPMS_ARRAY.x(:,i)    = [aida_data(i).bpms.x];
    BPMS_ARRAY.y(:,i)    = [aida_data(i).bpms.y];
    BPMS_ARRAY.tmit(:,i) = [aida_data(i).bpms.tmit];
    BPMS_ARRAY.stat(:,i) = [aida_data(i).bpms.stat];
    BPMS_ARRAY.good(:,i) = [aida_data(i).bpms.goodmeas];
    
    TORO_ARRAY.name(:,i) = {aida_data(i).toro.name};
    TORO_ARRAY.tmit(:,i) = [aida_data(i).toro.tmit];
    TORO_ARRAY.stat(:,i) = [aida_data(i).toro.stat];
    TORO_ARRAY.good(:,i) = [aida_data(i).toro.goodmeas];
    
    KLYS_ARRAY.name(:,i) = {aida_data(i).klys.name};
    KLYS_ARRAY.phas(:,i) = [aida_data(i).klys.phase];
    KLYS_ARRAY.stat(:,i) = [aida_data(i).klys.stat];
    
end

% assign Z position and sort by Z
load('device_list.mat');
for j = 1:n_bpms
    BPMS_IND = strcmp(BPMS_ARRAY.name(j,1),BPMS.NAME);
    BPMS_ARRAY.z(j,:) = BPMS.Z(BPMS_IND);
end
for k = 1:n_toro
    TORO_IND = strcmp(TORO_ARRAY.name(k,1),TORO.NAME);
    TORO_ARRAY.z(k,:) = TORO.Z(TORO_IND);
end
for m = 1:n_klys
    KLYS_IND = strcmp(KLYS_ARRAY.name(m,1),KLYS.NAME);
    KLYS_ARRAY.z(m,:) = KLYS.Z(KLYS_IND);
end
[nil,bpms_by_z] = sort(BPMS_ARRAY.z);
[nil,toro_by_z] = sort(TORO_ARRAY.z);
[nil,klys_by_z] = sort(KLYS_ARRAY.z);

BPMS_ARRAY.name = BPMS_ARRAY.name(bpms_by_z(:,1),:);
BPMS_ARRAY.x    = BPMS_ARRAY.x(bpms_by_z(:,1 ),:);
BPMS_ARRAY.y    = BPMS_ARRAY.y(bpms_by_z(:,1 ),:);
BPMS_ARRAY.z    = BPMS_ARRAY.z(bpms_by_z(:,1 ),:);
BPMS_ARRAY.tmit = BPMS_ARRAY.tmit(bpms_by_z(:,1 ),:);
BPMS_ARRAY.stat = BPMS_ARRAY.stat(bpms_by_z(:,1 ),:);
BPMS_ARRAY.good = BPMS_ARRAY.good(bpms_by_z(:,1 ),:);

TORO_ARRAY.name = TORO_ARRAY.name(toro_by_z(:,1),:);
TORO_ARRAY.z    = TORO_ARRAY.z(toro_by_z(:,1 ),:);
TORO_ARRAY.tmit = TORO_ARRAY.tmit(toro_by_z(:,1),:);
TORO_ARRAY.stat = TORO_ARRAY.stat(toro_by_z(:,1),:);
TORO_ARRAY.good = TORO_ARRAY.good(toro_by_z(:,1),:);

KLYS_ARRAY.name = KLYS_ARRAY.name(klys_by_z(:,1),:);
KLYS_ARRAY.z    = KLYS_ARRAY.z(klys_by_z(:,1 ),:);
KLYS_ARRAY.phas = KLYS_ARRAY.phas(klys_by_z(:,1),:);
KLYS_ARRAY.stat = KLYS_ARRAY.stat(klys_by_z(:,1),:);

data.raw.arrays.BPMS=add_raw(BPMS_ARRAY, out.aida_UID,'AIDA');
data.raw.arrays.TORO=add_raw(TORO_ARRAY, out.aida_UID,'AIDA');
data.raw.arrays.KLYS=add_raw(KLYS_ARRAY, out.aida_UID,'AIDA');