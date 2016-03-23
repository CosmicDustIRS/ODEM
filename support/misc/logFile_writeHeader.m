function logFile_writeHeader
%This function prepares the header of the logfile with listing up of all
%variables defined in the simulation

%% Get variables from Workspace

global m_h2o Kb Sb AU A_0 GM nucls_rad max_distance substep_distance...
    dust_to_gas_ratio bulk_density logFile_ID

folderName = evalin('base', 'outputFolder_Name');
dt = evalin('base', 'dt');
dt_nearby = evalin('base', 'dt_nearby');
dt_spawn = evalin('base', 'dt_spawn');
n_nodes = evalin('base', 'n_nodes');
size_min = evalin('base', 'size_min');
size_max = evalin('base', 'size_max');
size_discrete = evalin('base', 'size_discrete');
F_adj_exponent = evalin('base', 'F_adj_exponent');
t_start_utc = evalin('base', 't_start_utc');
t_start_sav = evalin('base', 't_start_sav');
t_end_utc = evalin('base', 't_end_utc');
jet_activity = evalin('base', 'jet_activity');
% lat_min = evalin('base', 'lat_min');
% lat_max = evalin('base', 'lat_max');
% lon_min = evalin('base', 'lon_min');
% lon_max = evalin('base', 'lon_max');
jet_areas = evalin('base', 'jet_areas');
dt_jet_save = evalin('base', 'dt_jet_save');
pit_activity = evalin('base', 'pit_activity');
active_pits = evalin('base', 'active_pits');
act_surf = evalin('base', 'act_surf');
shape_model_path = evalin('base', 'shape_model_path');

%% Header
fprintf( logFile_ID, '\nLogfile for ODEM simulation on %s\n\n', folderName);

fprintf( logFile_ID, ['\n\n------------------------------------------------------------\n'...
    'User Input\n'...
    '------------------------------------------------------------\n\n']);
%% Table for constants
fprintf(logFile_ID, ['------------------------------\n'...
    'constants\n'...
    '------------------------------\n']);

Values_const = { m_h2o ; Kb ; Sb ; AU };

ParName_const = {'m_h2o' ; 'Kb' ; 'Sb' ; 'AU'  };
strParName_const = cellstr(ParName_const);

Comment_const = { 'Water molecular mass [kg]' ;...
    'Boltzmann constant [J/K]';...
    'Stefan-Boltzmann constant [W/m2K4]';...
    'Astronomical unit [km]' };
strComment_const = cellstr(Comment_const);

writeToFile( strParName_const, Values_const, strComment_const);


%% Table for model parameters
fprintf(logFile_ID, ['\n------------------------------\n'...
    'model parameters\n'...
    '------------------------------\n']);

Values_model = { dt ; dt_nearby ; dt_spawn ; n_nodes ; ...
    size_min ; size_max ; size_discrete ; F_adj_exponent ; ...
    t_start_utc ; t_start_sav ; t_end_utc};

ParName_model = { 'dt' ; 'dt_nearby' ; 'dt_spawn' ; 'n_nodes' ; ...
    'size_min' ; 'size_max' ; 'size_discrete' ; 'F_adj_exponent' ; ...
    't_start_utc' ; 't_start_sav' ; 't_end_utc' };
strParName_model = cellstr(ParName_model);

Comment_model = { 'Time step [s]' ; 'Time step for nearby particles [s]';...
    'Time between spawning new particles [s]' ; 'Number of ice patches' ; ...
    'Minimum particle diameter [m]' ; 'Maximum particle diameter [m]' ; ...
    'Boolean to run only one particle size' ; 'Exponent to adjust mass distribution' ; ...
    'Start date for simulation' ; 'Start date for saving escaping particles' ;...
    'End date for simulation' };
strComment_model = cellstr(Comment_model);

writeToFile( strParName_model, Values_model, strComment_model);


%% Table for jet parameters
fprintf(logFile_ID, ['\n------------------------------\n'...
    'Jet parameters\n'...
    '------------------------------\n']);

Values_jet =  { jet_activity ; dt_jet_save };

ParName_jet = { 'jet_activity' ; 'dt_jet_save' };
strParName_jet = cellstr(ParName_jet);

Comment_jet = { 'Boolean for integration of jet activity' ; ...
    'Time between saving jet data to output file [s] (needs to be a multiple of dt)'};
strComment_jet = cellstr(Comment_jet);

writeToFile( strParName_jet, Values_jet, strComment_jet);

if jet_activity == 1
    size_ja = size(jet_areas,1);
    fprintf(logFile_ID, '\n              lat_min  lat_max  lon_min  lon_max\n');
    for i=1:size_ja
    fprintf(logFile_ID, 'jet_area(%d):      %3d      %3d      %3d      %3d\n', i, jet_areas(i,:));
    end
end


%% Table for active pit parameters
fprintf(logFile_ID, ['\n------------------------------\n'...
    'Pit parameters\n'...
    '------------------------------\n']);

Values_pit = {pit_activity};

ParName_pit = {'pit_activity'};
strParName_pit = cellstr(ParName_pit);

Comment_pit = {'Boolean for integration of active pits (0/1)'};
strComment_pit = cellstr(Comment_pit);

writeToFile( strParName_pit, Values_pit, strComment_pit);

if pit_activity == 1
    size_ap = size(active_pits,1);
    fprintf(logFile_ID, '\n                lat  lon  rad\n');
    for i=1:size_ap
    fprintf(logFile_ID, 'active_pit(%d):  %3d  %3d  %3d\n', i, active_pits(i,:));
    end
end

%% Table for comet info
fprintf(logFile_ID, ['\n------------------------------\n'...
    'Comet info\n'...
    '------------------------------\n']);

Values_comet = { A_0 ; GM ; nucls_rad ; max_distance ; substep_distance ;...
    act_surf ; dust_to_gas_ratio ; bulk_density ;shape_model_path };

ParName_comet = { 'A_0' ; 'GM' ; 'nucls_rad' ; 'max_distance' ; ...
    'substep_distance' ; 'act_surf' ; 'dust_to_gas_ratio' ; ...
    'bulk_density' ; 'shape_model_path' };
strParName_comet = cellstr(ParName_comet);

Comment_comet = { 'Comet Albedo[-]' ;...
    'Standard gravitational parameter [m3/s2]' ;...
    'Body norm radius [m]' ;...
    'Distance at which particles are terminated [m]' ;...
    'Distance below which integration time step is lowered [m]' ;...
    'Fraction of active comet surface (ice) [-]' ;...
    'Dust to gas ratio [-]' ;...
    'Pariticle bulk density [kg/m3]' ;...
    'Location of shape model binary kernel'};
strComment_comet = cellstr(Comment_comet);

writeToFile( strParName_comet, Values_comet, strComment_comet);

%% Start of log
fprintf( logFile_ID, ['\n\n------------------------------------------------------------\n'...
    'Command Window Output\n'...
    '------------------------------------------------------------\n\n']);
end

function writeToFile( strParName, values, strComment)
% This function writes the variables to the logfile with proper formatting

global logFile_ID

strTabbing = { '\t' ; '\t\t' ; '\t\t\t' ; '\t\t\t\t'; '\t\t\t\t\t'};
size_Values = size(values,1);
for i=1:size_Values

%% calculating tabbing lengths    
    length_tab1 = floor(length(strParName{i})/4);
    t1 = 5-length_tab1;
    if t1 < 1
        t1 = 1;
    end
    
    if ischar(values{i})
        length_tab2 = floor(length(values{i})/4);
    elseif ~mod(values{i},1)
        length_tab2 = floor(numel(num2str(values{i}))/4);
    elseif isfloat(values{i})
        length_tab2 = floor((numel(num2str(values{i}))+4)/4);
    end
    t2 = 5-length_tab2;
    if t2 < 1
        t2 = 1;
    end

%% writing values to file with proper formatting
    if ischar(values{i})
        fprintf(logFile_ID, ['%s' strTabbing{t1} '%s' strTabbing{t2} '%s\t\n'],...
            strParName{i}, values{i}, strComment{i});
    elseif ~mod(values{i},1)
        fprintf(logFile_ID, ['%s' strTabbing{t1} '%i' strTabbing{t2} '%s\t\n'],...
            strParName{i}, values{i}, strComment{i});
    elseif isfloat(values{i})
        fprintf(logFile_ID, ['%s' strTabbing{t1} '%0.3e' strTabbing{t2} '%s\t\n'],...
            strParName{i}, values{i}, strComment{i});
    end   
end
end