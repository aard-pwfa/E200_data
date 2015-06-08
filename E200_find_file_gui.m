function path = E200_find_file_gui()
    prefix=get_remoteprefix();
    searchpath = fullfile(prefix,'/nas/nas-li20-pm00/');

    searchpath = recent_dir(searchpath);
    searchpath = recent_dir(searchpath);
    searchpath = recent_dir(searchpath);
    searchpath = recent_dir(searchpath);
    
    searchlist = {{'scan_info.mat','scan'},{'filenames.mat','daq'}};
    
    settype='none';
    filtstr='';
    for searchstr=searchlist
    	desiredfiles=dir(fullfile(searchpath,['*' searchstr{1}{1}]));
    	if size(desiredfiles,1)>0
    		settype=searchstr{1}{2};
    		filtstr=searchstr{1}{1};
    		break;
    	end
    end
    
    switch settype
    	case 'scan'
    		defaultfile=[third '_' filtstr];
    	case 'daq'
    		defaultfile=desiredfiles(1).name;
    	case 'none'
    		defaultfile='';
    end
    
    curpath=pwd;
    cd(searchpath);
    [Filename,Pathname,FilterIndex]=uigetfile('*.mat','Open data file',defaultfile);
    cd(curpath);

    path = fullfile(Pathname, Filename)
end
