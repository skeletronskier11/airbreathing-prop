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

% Specific heat @ constant pressure
cpa = 1.005 ;   % cold stream
cpg = 1.148 ;   % hot stream

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
Ta = 216.8 ;    % atm temp (K)
Pa = 0.224 ;    % atm pressure (bar)

% Plane Characteristics
Sw = 127 ;      % wing area
Wto = 90000 ;   % weight (takeoff)
W = Wto * 0.85 ;% weight
T = 44847.7 ;   % thrust

% Static Thermo Calc
Ts = Ta * (1 + (gc - 1) / 2 * (M0 ^ 2)) ;
P0 = Pa * (1 + (gc - 1) / 2 * (M0 ^ 2)) ^ (gc / (gc - 1)) ;

%% VARIABLE BPR ANALYSIS

% -- Intake -- (0 -> 1)
P01 = eta_i * P0 ;
T01 = (eta_i) ^ ((gc - 1) / gc) * Ts ;

% -- Fan -- (1 -> 2)
P02 = pi_f * P01 ;
T02 = T01 + (T01 - Ts) / eta_f ;

% -- Compressor -- (2 -> 3)
P03 = pi_c * P02;
T03 = T02 + (T02 - T01) / eta_c;

% -- Combustor -- (3 -> 4)
P04 = pi_b * P03;
Q = cpg * (T04 - T03) * 1000 ;

% -- HP Turbine -- (4 -> 5)
Wc = cpa * (T03 - T02) ;    % Work on compressor
Wt = Wc / eta_m ;           % Work on turbine

T_drop = Wt / cpg ;
T05 = T04 - T_drop ;
T5s = T04 - (T04 - T05) / eta_t ;

P05 = P04 * (T5s / T04) ^ (gh / (gh - 1)) ;

% -- LP Turbine -- (5 -> 6)
Wf = cpa * (T02 - T01) * (BPR + 1) ;    % Work on fan
Wlpt = Wf / eta_m ;

T_drop2 = Wlpt / cpg ;
T06 = T05 - T_drop2 ;
T6s = T05 - (T05 - T06) / eta_t ;

P06 = P05 * (T6s / T05) .^ (gh / (gh - 1)) ;

% -- Bypass Exhaust -- (6 -> 8)
T8s = T02 * (Pa / P02) ^ ((gc - 1) / gc) ;
T8 = T02 - eta_f * (T02 - T8s) ;

V8 = sqrt(2 * cpa * 1000 * (T02 - T8)) ;

% -- Core Exhaust -- (8 -> 9)
T9s = T06 .* (Pa ./ P06) .^ ((gh - 1) / gh) ;
T9 = T06 - eta_c * (T06 - T9s) ;

V9 = sqrt(2 * cpg * 1000 * (T06 - T9)) ;

% Thrust / Mass Flow Calculation
m_dot_c_ratio = BPR .* (1 ./ (BPR + 1)) ;
m_dot_h_ratio = 1 ./ (BPR + 1) ;
m_dot_a = T ./ ((m_dot_c_ratio * V8) + (m_dot_h_ratio .* V9)) ;

T_m_dot = T ./ m_dot_a ;

m_dot_h = m_dot_h_ratio .* m_dot_a ;
m_dot_c = m_dot_c_ratio .* m_dot_a ;

% TSFC
f_actual = ((cpg * T03) - (cpa * T02)) / (eta_b * (hf - (cpg * T03))) ;
m_dot_f = f_actual * m_dot_h ;

TSFC = 3600 * m_dot_f / T ;

% Efficiencies
a = sqrt(gc * 287 * M0) ;

eta_overall_t = 0.5 .* (m_dot_h .* (V9 .^ 2) + m_dot_c .* (V8 .^ 2) - m_dot_a .* (a ^ 2)) ./ (m_dot_f * Q) ;

eta_overall_p = 2 * a * (m_dot_c .* (V8 - a) + m_dot_h .* (V9 - a)) / (m_dot_h .* (V9 .^ 2) + m_dot_c .* (V8 .^ 2) - m_dot_a * (a ^ 2)) ;

figure;
plot(BPR, eta_overall_t, 'LineWidth', 2);
xlabel('Bypass Ratio (BPR)');
ylabel('Overall Thrust Efficiency (\eta_{overall,t})');
title('Overall Thrust Efficiency vs Bypass Ratio');
grid on;
