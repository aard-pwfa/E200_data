function data=E200_load_data(pathstr,varargin)
% E200_LOAD_DATA  Convert original, binary data into a new file format and load into memory
%   DATA = E200_LOAD_DATA(FILENAME) converts FILENAME 
%   into the new file format and loads it into memory.
%
% Inputs:
%    FILENAME:    Relative or absolute location of
%             a directory, scan, or filenames.mat file
%
% Outputs:
%    DATA:        E200 data structure


    % Get valid parts of filename to use
    [dir_beg,dir_mid,filename,data_source_type]=get_valid_filename(pathstr);
    
    % Full path to file to load
    loadpath=fullfile(dir_beg,dir_mid,filename);

    % Split filename into root, extension
    [discard,filename_rt,filename_ext]=fileparts(filename);
    filename_final=[filename_rt '_processed' filename_ext];

    % Processed file info
    processed_file_dir = fullfile(dir_beg,dir_mid);
    processed_file_dir = regexprep(processed_file_dir,'nas/nas-li20-pm0.','processed_data');
    processed_file_path=fullfile(processed_file_dir,filename_final);

    % Get the hostname of the computer.
    % [status,hostname]=unix('hostname');
    % hostname = strrep(hostname,sprintf('\n'),'');
    % isfs20=strcmp(hostname,'facet-srv20');
    isfs20_bool = isfs20();
    
    % Run certain things depending on which machine you're on.
    % facet-srv20 gets special treatment: no files saved!
    exist_type = exist(processed_file_path);
    already_exists=(exist_type==2 || exist_type==7);
    switch data_source_type
    case '2014'
        if isfs20_bool
            % data=E200_gather_data(loadpath);
            load(loadpath)
        else
            load(loadpath)
            data.VersionInfo.remotefiles.dat=true;
            data.VersionInfo.remotefiles.comment = 'Indicates whether files are stored on a remote disk (and getpref(''FACET_data'',''prefix'') should be used.';
        end
    otherwise
        error('Shouldn''t get here!!!');
    end
end
