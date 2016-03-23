clear
close(gcf)
display(' ---  Outgassing and Dust Emission Model for 67P  ---');
%% add paths
addpath('mice/src/mice/')
addpath('mice/lib')
addpath('alpha_dsk_matlab/src/dskmice/')
addpath('alpha_dsk_matlab/lib')
addpath('support/integration')
addpath('support/misc')
addpath('support/physics')
addpath('support/plot')
addpath('support/')
cspice_furnsh( 'kernels.tm' ); 
%profile on

%% Constants
global m_h2o Kb Sb A_0 GM nucls_rad f max_distance N_factor AU cmap  ...
    particle_production_rate substep_distance rot_vector rad_per_sec gasProd_total ...
    dust_to_gas_ratio bulk_density redepos_mtot logFile_ID

% Constants:
m_h2o = 18.01528/1000 / 6.02214e23;     % Water molecular mass [kg]
Kb = 1.38e-23;                          % Boltzmann constant [J/K]
Sb = 5.670373e-8;                       % Stefan-Boltzmann constant [W/m2K4]
AU = 149597870.7;                       % Astronomical unit [km]  
%% Parameters

% Comet info:
A_0 = .06;                          % Comet Albedo [-]
GM = 6.674e-11 * 1e13;              % Standard gravitational param. [m3/s2]
nucls_rad = 2000;                   % Body norm radius [m] ??OBSOLETE??
max_distance = 20e3;                % Distance at which particles are terminated [m]
substep_distance = 2700;            % Distance below which integration time step is lowered [m]
act_surf = 0.010;                   % Fraction of active comet surface (ice) [-]
dust_to_gas_ratio = 4;              % Dust to gas ratio [-]
bulk_density = 1000;                % Pariticle bulk density [kg/m3]
shape_model_path = ...              % Location of shape model binary kernel    
    './kernels/DSK/CSHP_DV_170_01_______00243_20000.BDS';

% Model param.:
particle_production_rate = 100000;    % Approx. particle spawn rate [1/hour]
dt = 20;                           % Time step [s]
dt_nearby = dt/5;                  % Time step for nearby particles [s]
dt_spawn  = dt;                     % Time between spawning new particles [s] (needs to be a multiple of dt, e.g. 1*dt, 2*dt,...)
n_nodes = 3000;                     % Number of ice patches
size_min = 1e-6;                   % Minimum particle size [m]         (diameter)
size_max = 1e-2;                % Maximum particle size [m]
size_discrete = 0;                  % Set this to run only one particle size [m]
F_adj_exponent = .2;               % Exponent to adjust mass distribution
t_start_utc = '2015 apr 12 18:00';        % Start date for simulation
t_start_sav = '2015 apr 12 18:00';         % Start date for saving escaping partilces
t_end_utc   = '2015 apr 12 19:30';         % End date for simulation

%jets
jet_activity = 1;                   % Boolean for integration of jet activity (0/1)
jet_areas = ...                      % Array for active areas [lat_min lat_max lon_min lon_max] [deg] - seperate multiple areas by ";"
    [55 80 220 360 ; 0 20 340 360 ; 0 20 0 10 ; -30 30 120 160];
dt_jet_save = 30*dt;                % Time between saving jet data to output file [s] (needs to be a multiple of dt)

%pits
pit_activity = 1;                   % Boolean for integration of active pits (0/1)
active_pits = ...                   % Array for active pits [lat lon radius] - seperate multiple pits by ";"
    [70 220 110; 69 205 55; 68 195 70; 78 198 80; 57 239 115; 42 8 125; 35 9 130 ; ...
    0 330 100 ; 5 330 100; 5 345 100; 15 325 100; 15 330 100; 15 335 100; ...
    40 345 100; 15 10 100; 12 10 100; 15 15 100; 15 25 100; 30 15 100; ...
    40 15 100; 10 150 100; 0 130 100; -5 115 100];          

% Animation param.:
dt_frame  = dt;                     % Time between frames [s] (set to 0 to disable animation)(needs to be a multiple of dt, e.g. 1*dt, 2*dt,...)
antialiasing= 0;                    % Set Anti-Aliasing
plot_shadow = 0;                    % Set wether or not to plot shadow the comet casts on itself (increases runtime)
plot_skybox = 0;                    % Set wether or not to plot star background.
plot_jetPlates = 1;                 % Set wether or not to plot jet region
plot_pitPlates = 1;                  % Set wether or not to plot active pits
plot_time = 1;                      % Set wether or not to plot utc-time to frames
plot_vecLatLonJet = 0;              % Set wether or not to plot lat/lon vectors
stereoview  = 0;                    % Set this to 1 to generate 2 views of every frame
viewer_distance = 60;             % Set distance of scenery to your face [cm]. Decrease to increase 3d effect. 

% Data Ouput
outputFolder_Name = strjoin( {'/media/frederik/551F-6F3D/Diplomarbeit', datestr(datetime('now'),'yyyy-mm-dd_HH-MM-SS')},{'/'} );    % Set where to store output data
logFile_Path = ...
    strjoin( {outputFolder_Name, 'log.txt'},{'/'} );        % Set where to store logfile
frames_path = ...
    strjoin( {outputFolder_Name, 'FRAMES/'},{'/'} );           % Set where to store the animation frames


%% -----Start-----

%% Create output folder & Prepare logFile
mkdir(outputFolder_Name);
logFile_ID = fopen( logFile_Path, 'w');
logFile_writeHeader;
diary(logFile_Path);

%% Prepare some variables
N_factor = 1; %only needed for discrete particle sizes
gasProd_total = 0;
redepos_mtot = [];
if size_discrete == 0
    fprintf('Minimum particle size [mm]:         %.3f\n',size_min*1e3);
    fprintf('Maximum particle size [mm]:         %.3f\n',size_max*1e3);
    mmin = 4/3*3.14*bulk_density*(size_min/2)^3;  % Minimum particle mass [kg]
    mmax = 4/3*3.14*bulk_density*(size_max/2)^3;  % Maximum particle mass [kg]
    Find_Bin_MassFraction( mmin, mmax, F_adj_exponent );
else
    fprintf('Discrete particle size [mm]:        %.3f\n',size_discrete*1e3);
end
area = 4*pi*nucls_rad^2*act_surf/n_nodes;       % Area of ice tiles [m2]
fprintf('Ice tile diameter [m]:              %.1f\n',2*sqrt(area/pi));
r=[];           % position array
v=[];           % velocity array
r2=[];          % position array for particles near the nucleus
v2=[];          % velocity array for particles near the nucleus

states_leave=[];
rosetta_init_distance = 0;
et_start = cspice_str2et(t_start_utc);
et_start_sav = cspice_str2et(t_start_sav);
et_end = cspice_str2et(t_end_utc);
etime = et_start;
Update_RotMatrix( et_start );
if jet_activity || pit_activity
    jet_int = 1;            % integer value for counting save-states of jets            
    dirRay_latlon = [];     % array for direction rays of jet latitude/longitude
end
if dt_frame ~= 0
    [fig, cmap] = Create_Figure( );
    mkdir(frames_path);
    if stereoview == 1
        mkdir([frames_path, 'second_view']);
    end
    if plot_skybox == 1
        Plot_Skybox();
    end
end
f=1; %frame counter
tic

%% Load shape model and spawn random ice patches (nodes)
% plates [3, #plates]       elements are the plates vertex numbers
% vertices [3, #vertices]   each vertex is a 3-vector (m)
% plcenter [#plates, 4]     vector of each plates center + vectorlength
% plnorm [#plates, 3]       normal vector of each plate
% np                        number of plates
% nv                        number of vertices
% shape_handle              plateID
% nodes_bfix [n_nodes, 8]   contains columnwise [plcenter_vector(3), plnorm_vector(3), node_r2, plate_index]
[plates, vertices, plcenter, plnorm, np, nv, shape_handle] ...
    = Load_ShapeModel( shape_model_path );
nodes_bfix = Create_Nodes_Duck_RND( n_nodes , area, plcenter, plnorm);

%% Define active pits in shape model 
% Find active pit plates on shape model by lat/lon and create ice tiles
% with given radius.
% Sort out jetPlates, that are already in nodes_bfix due to randomly
% placement
% Add directionRays of lon/lat-vector to dirRay_latlon
% Add jetPlates to nodes_bfix
if pit_activity == 1
 
    [ nodes_bfixPit , pitPlateID, dirRay_latlon ] = ...
       Find_Plates_Pits(active_pits, dirRay_latlon, plates, vertices, ...
       plcenter, plnorm, shape_handle, plot_vecLatLonJet);

    nodes_bfix = ...
    [nodes_bfix(~ismember(nodes_bfix(:,8),nodes_bfixPit(:,8)),:) ; nodes_bfixPit]; 
end

%% Define active areas in shape model
% Find active area plates on shape model by lat/lon range and create ice 
% tiles with given radius.
% Sort out jetPlates, that are already in nodes_bfix due to randomly
% placement and active pits. 
% Add directionRays of lon/lat-vector to dirRay_latlon
% Add jetPlates to nodes_bfix
if jet_activity == 1

    [ nodes_bfixJet , jetPlateID, dirRay_latlon ] = ...
       Find_Plates_Jets( jet_areas, dirRay_latlon, plates, vertices, ...
       plcenter, plnorm, shape_handle, plot_vecLatLonJet);
   
    nodes_bfix = ...
        [nodes_bfix(~ismember(nodes_bfix(:,8),nodes_bfixJet(:,8)),:) ; nodes_bfixJet];

end

%% Integration
for t=0:dt:(et_end-et_start)
    %% Get Sun position and node positions+activity
    [sun_dis, sun_dir] = Get_Sun_Distance_and_Direction( etime );
    [nodes_pos, nodes_norm, nodes_int] = Update_Nodes( nodes_bfix, sun_dis, sun_dir, shape_handle );
    [nodes_norm, Zd_bin] = Find_Activity( nodes_norm, dt, etime);
    
    %% Spawn particles
    if mod(t,dt_spawn) < dt
        if size_discrete == 0
            [r2, v2] = Spawn_Particles_MC( r2, v2, nodes_pos, Zd_bin, dt_spawn );
        else
            [r2, v2] = Spawn_Particles_discrete( r2, v2, nodes_pos, nodes_int, Zd_bin, dt_spawn, size_discrete);
        end  
    end
    %% Integrate far space
	[r, v] = RK4( r, v, dt ,nodes_pos , nodes_norm );
    
    %% Integrate nearby space with substeps
    for t_n=0:dt_nearby:dt-dt_nearby
        rot_nodes_substep = cspice_axisar(rot_vector, dt_nearby*rad_per_sec);
        [r2, v2] = RK4( r2, v2, dt_nearby ,nodes_pos , nodes_norm ); 
        for i=1:size(nodes_pos,1)                                           % Apply small rotation to
            nodes_pos(i,1:3) = rot_nodes_substep * nodes_pos(i,1:3).';     % the nodes to account for 
            nodes_norm(i,1:3) = rot_nodes_substep * nodes_norm(i,1:3).';   % comet rotation between
        end 
    end
    
    %% Update time, rotation and particle pool
    etime = etime + dt;
    Update_RotMatrix( etime );
    if (jet_activity || pit_activity) &&  ~mod((etime - et_start_sav), dt_jet_save) && size(r,1) ~= 0
        time = repmat(etime,size(r,1),1);
        states_jet{jet_int} = [r(:, 1:3), v(:, 1:3), time, r(:,4), v(:,4)];
        jet_int = jet_int+1;
    end
    
    if etime >= et_start_sav        
        states_leave = Save_States_GTMAX( states_leave, etime, r, v );
    end
    [r, v, r2, v2] = Kill_Particles_Duck( r, v, r2, v2, plcenter, plnorm, et_start_sav, etime);
    
    %% Plot
    if mod(t,dt_frame) < dt && dt_frame ~=0
        [gSunDir, gRot, gTerm, gSun] = Plot_Environment( sun_dir );
        
        if plot_shadow == 1
            gbody = Plot_Duck_Shadow( plates, vertices, np, nv, plcenter, plnorm, shape_model_path, sun_dir);
        else
            gbody = Plot_Duck( plates, vertices, np, nv);
        end
        
        if plot_jetPlates == 1                                              %%%
            gjetPlate = Plot_JetPlate( plates, vertices, nv, jetPlateID);   %%%
        end                                                                 %%%
        
        if plot_pitPlates == 1                                              %%%
            gpitPlate = Plot_PitPlate( plates, vertices, nv, pitPlateID);   %%%
        end                                                                 %%%
        
        if plot_vecLatLonJet == 1
            gLatLonVert_Jet = Plot_vectorsLatLon_Jet(dirRay_latlon);
        end
        
        gdust = Plot_Particles(r, v, r2, v2);
        CamPos_Rosetta(etime, sun_dir);
        drawnow;                                    % Replot
        
        if antialiasing == 1
            myaa;          %Anti-Aliasing
        end
        
        if plot_time == 1
            t_et = et_start+t;
            t_utc = cspice_etcal( t_et );
            gTime = uicontrol('Style','Text',...
                    'BackgroundColor', [0 0 0.03],...
                    'ForegroundColor', 'white',...
                    'Units', 'normalized',...
                    'Position', [0.75 0.1 0.2 0.1],...
                    'FontSize', 14,...
                    'String', t_utc); 
        end
        
        imwrite(getfield(getframe(gca),'cdata'),strcat(frames_path,int2str(f),'.png'));
        
        if antialiasing == 1
            close(figure(2));   %close anti-alisased picture 
            gfc = figure(1);    %and return to animation figure
        end
        
        if stereoview == 1
            CamPos_Stereo(viewer_distance,0);
            
            if antialiasing == 1
                myaa;          %Anti-Aliasing
            end
            
            imwrite(getfield(getframe(gca),'cdata'),strcat([frames_path,'second_view/'],int2str(f),'.png'));
            
            if antialiasing == 1
                close(figure(2));   %close anti-alisased picture
                gfc = figure(1);    %and return to animation figure
            end
            
        end

        delete([gbody, gdust, gSunDir, gRot, gTerm, gSun,]);
        
        if plot_jetPlates == 1
            delete(gjetPlate)
        end
        
        if plot_pitPlates == 1
            delete(gpitPlate)
        end
        
        if plot_time == 1
            delete(gTime)
        end
        
        if plot_vecLatLonJet == 1
            delete(gLatLonVert_Jet)
        end
    end
    f=f+1;  %frame counter
end
%close(gcf);
%% Finalise
if size(states_leave,1)~= 0
    save([outputFolder_Name '/' 'states_' regexprep(t_start_sav,'[^\w'']','') '_to_' ...
        regexprep(t_end_utc,'[^\w'']','') '.txt'],'states_leave','-ascii');
end
if size(redepos_mtot,1)~= 0
    save([outputFolder_Name '/' 'redepos_' regexprep(t_start_sav,'[^\w'']','') '_to_' ...
        regexprep(t_end_utc,'[^\w'']','') '.txt'],'redepos_mtot');
end
if size(states_jet,1)~= 0
    states_jet_path = ...
        strjoin( {outputFolder_Name, 'Jet_Data/'},{'/'} ); 
    mkdir(states_jet_path);
    for i=1:(jet_int - 1)
        states_jet_temp = states_jet{i};
        jet_time = cspice_et2utc(states_jet_temp(1,7), 'C', 0);
        save([outputFolder_Name '/Jet_Data/' 'states_jet_at_' ...
            regexprep(jet_time,'[^\w'']','') '.txt'], 'states_jet_temp', '-ascii');
    end
end
fprintf('Average water production [kg/s]:    %.2f\n', gasProd_total/(et_end-et_start) * area);
toc
display(' ---  Simulation finished!');

diary('off');
fclose(logFile_ID);
