function out = recent_dir(path)
    % ==============================
    % Get directories
    % ==============================
    dirs = dir(path);

    % ==============================
    % Convert to structure
    % ==============================
    dirs = struct2cell(dirs);

    % ==============================
    % Order by date
    % ==============================
    date         = dirs(5,:);
    date         = cell2mat(date);
    [ignore,ind] = sort(date);
    dirs_sort    = dirs(:,ind);

    % ==============================
    % Return recent
    % ==============================
    dir_recent = dirs_sort{1, end};

    % ==============================
    % Join with path and return
    % ==============================
    out = fullfile(path, dir_recent);
end
