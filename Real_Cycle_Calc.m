clc ;
close all ;
clear all ;

BPR = linspace(5,20,25) ;   % bypass ratio
FPR = linspace(1.2,20,25) ; % fan pressure ratio
CPR = linspace(20,50,25) ;  % compressor ratio

% Mach
M0 = 0.85 ;     % freestream mach

% Gamma
gc = 1.4 ;      % heat ratio (air)
gh = 1.333 ;    % heat ratio (air/fuel mixture)

% Combustion
T04 = 1560 ;    % turbine inlet temp
hf = 43100 ;    % fuel energy

% Pressure Ratios
pi_f = 1.35 ;   % fan ratio
pi_c = 30 ;     % compressor ratio
pi_b = 0.96 ;   % combustion ratio

% Efficiencies
eta_i = 0.98 ;  % intake
eta_f = 0.91 ;  % fan
eta_c = 0.9 ;   % compressor
eta_b = 0.99 ;  % combustor
eta_t = 0.93 ;  % turbine
eta_m = 0.99 ;  % mechanical
eta_j = 0.99 ;

% Atmospheric Conditions
Ta = 216.8 ;      % atm temp (K)
Pa = 0.224 ;     % atm pressure (bar)

% Plane Characteristics
Sw = 127 ;      % wing area
Wto = 90000 ;   % weight (takeoff)
W = Wto * 0.85 ;% weight
T = 44847.7 ;   % thrust

%% VARIABLE BPR ANALYSIS

% -- Intake -- (0 -> 1)
P01 = eta_i * P0 ;
P02 = pi_f * P01 ;
