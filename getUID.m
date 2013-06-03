function UID = getUID(data_set_num, step_num, pulseID, epics_pid)

shot_num = find(pulseID==epics_pid, 1, 'first');

UID = 1e8*data_set_num + 1e4*step_num + shot_num;


end