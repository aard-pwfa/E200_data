function datasaved=E200_save_remote(data)
	dataorig=E200_load_data(data.VersionInfo.loadrequest);
	datanew=E200_merge(data,dataorig);
	% datasaved=save_data(datanew,fullfile(getpref('FACET_data','prefix'),datanew.VersionInfo.originalpath,datanew.VersionInfo.originalfilename),false);
	prefix=get_remoteprefix();
	savepath=fullfile(prefix,datanew.VersionInfo.originalpath,datanew.VersionInfo.originalfilename);
	datasaved=save_data(datanew,savepath,false);
end
