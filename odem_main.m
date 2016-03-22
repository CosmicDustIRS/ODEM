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
profile on
%% Constants
global m_h2o Kb Sb A_0 GM f N_factor AU cmap  ...
    particle_production_rate bulk_density reverseStr nucls_rad
% Constants:
m_h2o = 18.01528/1000 / 6.02214e23;     % Water molecular mass [kg]
Kb = 1.38e-23;                          % Boltzmann constant [J/K]
Sb = 5.670373e-8;                       % Stefan-Boltzmann constant [W/m2K4]
AU = 149597870.7;                       % Astronomical unit [km]  

%% Parameters
% Comet info:
A_0 = .06;                          % Comet Albedo [-]
GM = 6.674e-11 * 1e13;              % Standard gravitational param. [m3/s2]
max_distance = 20e3;                % Distance at which particles are terminated [m]
nucls_rad = 2000;                   % Needed for ploting [m]
act_surf = 0.010;                   % Fraction of active comet surface (ice) [-]
dust_to_gas_ratio = 4;              % Dust to gas ratio [-]
bulk_density = 1000;                % Pariticle bulk density [kg/m3]
shape_model_path = ...              % Location of shape model binary kernel    
    'kernels\DSK\CSHP_DV_170_01_______00243_20000.BDS';

% Model param.:
particle_production_rate = 2000;    % Approx. particle spawn rate [1/hour]
dt = 50;                            % Time step [s]
t_preint  = 5;                      % Time interval for preintegration of spawning particles [s] (!<10s)
n_preint  = 1;                      % Number of integration step to make during preintegration (>=1, choose this so that t_preint/n_preint = .5s at perihel, or = 5s 1year away from perihel)
n_nodes = 3000;                     % Number of ice patches
size_min = 10e-6;                   % Minimum particle size [m]         (diameter)
size_max = 10000e-6;                % Maximum particle size [m]
size_discrete = 0;                  % Set this to run only one particle size [m]
F_adj_exponent = .15;               % Exponent to adjust mass distribution
t_start_utc = '2014 aug 31';        % Start date for simulation
t_start_sav = '2014 sep 1';         % Start date for saving escaping partilces
t_end_utc   = '2014 oct 1';         % End date for simulation
data_path = ...
    'GBOsim\';                      % Set where to store the output data


% Animation param.:
dt_frame  = 0;                      % Time between frames [s] (set to 0 to disable animation)(needs to be a multiple of dt, e.g. 1*dt, 2*dt,...)
antialiasing= 0;                    % Set Anti-Aliasing
plot_shadow = 0;                    % Set wether or not to plot shadow the comet casts on itself (increases runtime)
plot_skybox = 0;                    % Set wether or not to plot star background.
stereoview  = 0;                    % Set this to 1 to generate 2 views of every frame
viewer_distance = 60;               % Set distance of scenery to your face [cm]. Decrease to increase 3d effect. 
frames_path = ...
    'D:\FRAMES\test\';              % Set where to store the animation frames

%% -----Start-----
%% Prepare some variables
gasProd_total = 0;
dustProd_total = 0;
if size_discrete == 0
    fprintf('Minimum particle size [mm]:         %.3f\n',size_min*1e3);
    fprintf('Maximum particle size [mm]:         %.3f\n',size_max*1e3);
    mmin = 4/3*3.14*bulk_density*(size_min/2)^3;  % Minimum particle mass [kg]
    mmax = 4/3*3.14*bulk_density*(size_max/2)^3;  % Maximum particle mass [kg]
    Find_Bin_MassFraction( mmin, mmax, F_adj_exponent );
else
    N_factor = 1; %only needed for discrete particle sizes
    fprintf('Discrete particle size [mm]:        %.3f\n',size_discrete*1e3);
end
area = 4*pi*nucls_rad^2*act_surf/n_nodes;       % Aera of ice tiles [m2]
fprintf('Ice tile diameter [m]:              %.1f\n',2*sqrt(area/pi));
r=[];           % position array
v=[];           % velocity array
SPI=[];         % Particle Spawn Index array (Contains the indexes of the facets the particles in the pool spawned from) 
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
    if plot_skybox == 1
        Plot_Skybox();
    end
end
f=0; %frame counter
reverseStr = '';
tic

%% Load shape model and spawn random ice patches (nodes)
[plates, vertices, plcenter, plnorm, plarea, np, nv, shape_handle, redepos_mtot] ...
    = Load_ShapeModel( shape_model_path );
nodes_bfix = Create_Nodes_Duck_RND( n_nodes , area, plcenter, plnorm, plarea);

%% Integration
for t=0:dt:(et_end-et_start)
    %% Get Sun position and node positions+activity
    [sun_dis, sun_dir] = Get_Sun_Distance_and_Direction( etime );
    [nodes_pos, nodes_norm, nodes_int] = Update_Nodes( nodes_bfix, sun_dis, sun_dir, shape_handle );
    [nodes_norm, Zd_bin, gasProd_total] = Find_Activity( nodes_pos, nodes_norm, dt, etime, dust_to_gas_ratio, gasProd_total, et_start_sav);

    %% Spawn particles
    if size_discrete == 0
        [r2, v2, SPI2] = Spawn_Particles_MC( nodes_pos, nodes_int, Zd_bin, dt );
    else
        [r2, v2, SPI2] = Spawn_Particles_discrete( nodes_pos, nodes_int, Zd_bin, dt, size_discrete, etime);
    end
    %% Pre-integration
    for n=0:n_preint
        [r2, v2] = RK4_noRotation( r2, v2, t_preint/n_preint, nodes_pos, nodes_norm); % Integrate particles just spawned with very small time step
    end
    [r, v, SPI, dustProd_total] = Check_if_lifted( r, v, r2, v2, SPI, SPI2, plcenter, plnorm, dustProd_total, et_start_sav, etime);
    

    %% Integrate all particles
	[r, v] = RK4( r, v, dt ,nodes_pos , nodes_norm );
        

    %% Update time, rotation and particle pool
    etime = etime + dt;
    Update_RotMatrix( etime );
    if etime >= et_start_sav        
        states_leave = Save_States_GTMAX( states_leave, etime, r, v, SPI, max_distance );
    end
    [r, v, SPI, redepos_mtot] = Kill_Particles_Duck( r, v, SPI, plcenter, plnorm, plarea, max_distance, et_start_sav, etime, size_discrete, redepos_mtot);
    

    %% Plot
    if dt_frame ~=0
        if mod(t,dt_frame) < dt 
            [gSunDir, gRot, gTerm, gSun] = Plot_Environment( sun_dir );
            if plot_shadow == 1
                gbody = Plot_Duck_Shadow( plates, vertices, np, nv, plcenter, plnorm, shape_model_path, sun_dir);
            else
                gbody = Plot_Duck( plates, vertices, np, nv);
            end
            gdust = Plot_Particles(r, v);
            CamPos_Rosetta(etime, sun_dir, max_distance);
            if antialiasing == 1
                myaa;          %Anti-Aliasing
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
            delete([gbody, gdust, gSunDir, gRot, gTerm, gSun]);
            f=f+1;  %frame counter
         end
    else
        f=1;
    end
    
    
    %% Display process
    progress = t/(et_end-et_start);
    msg = sprintf('Particle spawn rate [1/h]:          %.0f\n Progress:       %2.2f percent\n Time remaining: %2.2f hours\n',particle_production_rate, progress*100, (toc/progress-toc)/3600);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
end
fprintf(reverseStr);
%close(gcf);
profile off

%% Finalise
fprintf('Particle spawn rate [1/h] (end):    %.0f\n', particle_production_rate);
if size(states_leave,1)~= 0
    save([data_path,'states_' regexprep(t_start_sav,'[^\w'']','') '_to_' ...
        regexprep(t_end_utc,'[^\w'']','')],'states_leave');
end
if size(redepos_mtot,1)~= 0
    save([data_path,'redepos_' regexprep(t_start_sav,'[^\w'']','') '_to_' ...
        regexprep(t_end_utc,'[^\w'']','')],'redepos_mtot');
end
fprintf('Average water production [kg/s]:    %.2f\n', gasProd_total/(et_end-et_start_sav));
fprintf('Absolut water production [kg]:      %.3e\n', gasProd_total);
if size_discrete == 0
    fprintf('Absolut dust production [kg]:       %.3e\n', dustProd_total);
end
toc
display(' ---  Simulation finished!');