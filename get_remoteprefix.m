function prefix=get_remoteprefix()
	def_prefix='/Volumes/PWFA_4big';

	% Get existing prefix, or default
	if ispref('FACET_data','prefix')
		prefix=getpref('FACET_data','prefix');
	else
		setpref('FACET_data','prefix',def_prefix);
		prefix=def_prefix;       
	end

	datapath=fullfile(prefix,'nas','nas-li20-pm00');
	if exist(datapath)~=7
		% Drive may not be mounted: warn user, allow to mount drive or change prefix.
		options={'Try again.','Locate folder containing /nas.'};
		button=options{1};

		% While the user tries again, and the datapath isn't a folder
		while strcmp(button,options{1}) && exist(datapath)~=7
			button=questdlg(sprintf(['WARNING: Path to data doesn''t exist:\n\n' datapath '\n\nDrive may not be mounted.']),'Data Not Found',options{1},options{2},options{1});
			if strcmp(button,options{2})
				prefix=uigetdir(prefix,options{2});
				if prefix==0
					error('No valid option selected.');
				end
				setpref('FACET_data','prefix',prefix);
				datapath=fullfile(prefix,'nas','nas-li20-pm01');
			end
		end
	end
end
