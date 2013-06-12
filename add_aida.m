function data = add_aida(data,aida_data,options)

n_a_shots = length(aida_data);

a_scan_step=ones(1,n_a_shots)*options.scan_step;

pulse_id = [aida_data.pulse_id];
option.AIDA_PID=pulse_id;
option.AIDA_SCANSTEP=a_scan_step;

EPICS_PID = data.raw.scalars.PATT_SYS1_1_PULSEID.dat;
EPICS_SCANSTEP = data.raw.scalars.step_num.dat;
EPICS_DATASET = data.raw.scalars.set_num.dat;

out = assign_UID(EPICS_PID,EPICS_SCANSTEP,EPICS_DATASET,option);