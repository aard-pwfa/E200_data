function datasaved=E200_save_remote(data)
	dataorig=E200_load_data(data.VersionInfo.loadrequest);
	datanew=E200_merge(data,dataorig);
	datasaved=save_data(datanew,fullfile(getpref('FACET_data','prefix'),datanew.VersionInfo.originalpath,datanew.VersionInfo.originalfilename),false);
end
