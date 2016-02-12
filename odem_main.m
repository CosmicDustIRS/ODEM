clear
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
profile on
%% Constants
global m_h2o Kb Sb A_0 GM nucls_rad f max_distance N_factor AU cmap  ...
    particle_production_rate substep_distance rot_vector rad_per_sec gasProd_total ...
    dust_to_gas_ratio bulk_density redepos_mtot rosetta_init_distance

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
    '.\Kernels\DSK\pcjo';

% Model param.:
particle_production_rate = 1200;    % Approx. particle spawn rate [1/hour]
dt = 90;                           % Time step [s]
dt_nearby = dt/15;                  % Time step for nearby particles [s]
dt_spawn  = dt;                     % Time between spawning new particles [s] (needs to be a multiple of dt, e.g. 1*dt, 2*dt,...)
n_nodes = 3000;                     % Number of ice patches
size_min = 500e-6;                   % Minimum particle size [m]         (diameter)
size_max = 10000e-6;                % Maximum particle size [m]
size_discrete = 0;                  % Set this to run only one particle size [m]
F_adj_exponent = .2;               % Exponent to adjust mass distribution
t_start_utc = '2014 aug 31';        % Start date for simulation
t_start_sav = '2014 sep 1';         % Start date for saving escaping partilces
t_end_utc   = '2014 oct 1';         % End date for simulation

% Animation param.:
dt_frame  = dt;                     % Time between frames [s] (set to 0 to disable animation)(needs to be a multiple of dt, e.g. 1*dt, 2*dt,...)
antialiasing= 0;                    % Set Anti-Aliasing
stereoview  = 1;                    % Set this to 1 to generate 2 views of every frame
plot_shadow = 1;                    % Set wether or not to plot shadow the comet casts on itself (increases runtime)
frames_path = ...
    'D:/FRAMES/redepos/';           % Set where to store the animation frames

%% -----Start-----
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
area = 4*pi*nucls_rad^2*act_surf/n_nodes;       % Aera of ice tiles [m2]
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
if dt_frame ~= 0
    [fig, cmap] = Create_Figure( );
    mkdir(frames_path);
    if stereoview == 1
        mkdir([frames_path, 'second_view']);
    end
    Plot_Skybox();
end
f=1; %frame counter
tic

%% Load shape model and spawn random ice patches (nodes)
[plates, vertices, plcenter, plnorm, np, nv, shape_handle] ...
    = Load_ShapeModel( shape_model_path );
nodes_bfix = Create_Nodes_Duck_RND( n_nodes , area, plcenter, plnorm);

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
    if etime >= et_start_sav        
        states_leave = Save_States_GTMAX( states_leave, etime, r, v );
    end
    [r, v, r2, v2] = Kill_Particles_Duck( r, v, r2, v2, plcenter, plnorm);
    
    %% Plot
    if mod(t,dt_frame) < dt && dt_frame ~=0
        [gSunDir, gRot, gTerm, gSun] = Plot_Environment( sun_dir );
        if plot_shadow == 1
            gbody = Plot_Duck_Shadow( plates, vertices, np, nv, plcenter, plnorm, shape_model_path, sun_dir);
        else
            gbody = Plot_Duck( plates, vertices, np, nv);
        end
        gdust = Plot_Particles(r, v, r2, v2);
        CamPos_Rosetta(etime, sun_dir);
        drawnow;                                    % Replot
        if antialiasing == 1
            myaa;          %Anti-Aliasing
        end
        imwrite(getfield(getframe(gca),'cdata'),strcat(frames_path,int2str(f),'.png'));
        if antialiasing == 1
            close(figure(2));   %close anti-alisased picture 
            gfc = figure(1);    %and return to animation figure
        end
        if stereoview == 1
            CamPos_Stereo(etime);
            if antialiasing == 1
                myaa;          %Anti-Aliasing
            end
            imwrite(getfield(getframe(gca),'cdata'),strcat([frames_path,'second_view/'],int2str(f),'.png'));
            if antialiasing == 1
                close(figure(2));   %close anti-alisased picture
                gfc = figure(1);    %and return to animation figure
            end
        end
        delete([gbody, gdust, gSunDir, gRot, gTerm, gSun]);
    end
    f=f+1;  %frame counter
end
%close(gcf);
%% Finalise
if size(states_leave,1)~= 0
    save(['states_' regexprep(t_start_sav,'[^\w'']','') '_to_' ...
        regexprep(t_end_utc,'[^\w'']','') '.txt'],'states_leave','-ascii');
end
if size(redepos_mtot,1)~= 0
    save(['redepos_' regexprep(t_start_sav,'[^\w'']','') '_to_' ...
        regexprep(t_end_utc,'[^\w'']','') '.txt'],'redepos_mtot');
end
fprintf('Average water production [kg/s]:    %.2f\n', gasProd_total/(et_end-et_start) * area);
toc
display(' ---  Simulation finished!');