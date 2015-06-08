function data = E200_load_file_gui()
    path = E200_find_file_gui();
    data = E200_load_data(path);
end
