% File: adaptive_Hopf.m
% Purpose: Matlab script for testing and tuning the Adaptive Frequency Oscillator Arduino program.
% Version: 1.0.0
% Date: 18-12-2018
% Created by: Martin Stokroos
% URL: https://github.com/MartinStokroos/adaptiveFreqOsc
% License: MIT License

% The adaptive Hopf frequency oscillator model was taken from:
% A.J.Ijspeert, Adaptive Frequency Oscillators, https://biorob.epfl.ch/cms/page-36365.html.
%
% This m-file is not an example of efficient matlab programming. It was written with the purpose to develop C-programming code.

clear all;
close all;
clc;

Fs=1000; % sampling frequency
Tfinal=10.0; % simulation time
T=1/Fs; % sampling Time = 1/Fs
t=linspace(0,Tfinal,Tfinal/T); % simulation time vector

plotvar1 = linspace(0,0,Tfinal/T);
plotvar2 = linspace(0,0,Tfinal/T);
plotvar3 = linspace(0,0,Tfinal/T);
x = 1;  % starting point of the oscillator. x=1 and y=0, starts as cosine. 
x_new = 0;
x_d = 0;
y = 0;
y_new = 0;
y_d = 0;
ohm = 10*2*pi; %10Hz
ohm_new = 0;
ohm_d = 0;

Epsilon = 15; % coupling strength (>0).
              % the oscillator locks faster for larger values, but it will also increase the ripple in the frequency. 

gamma = 100.0; % follows the amplitude of the stimulus better for larger values, but it may cause instability.  

mu = 1.0; % seems to scale the amplitude.


for n=1:Tfinal/T
    
    % input stimulus
    if n < Tfinal/(4*T) % apply step after 1/4th of the simulation time
        F = 0;
        %F = sin(2*pi*n*T);
    end
    if (n >= Tfinal/(4*T)) && (n < Tfinal/(4*T/3))
        %F = 0;
        F = sin(12.5*2*pi*n*T); %12.5Hz
    end
    if (n >= Tfinal/(4*T/3))
        %F = 0;
        F = 0;
    end

    % discretized adaptive Hopf
    x_d = gamma*( mu-(x^2 + y^2) )*x - ohm*y + Epsilon*F;
    y_d = gamma*( mu-(x^2 + y^2) )*y + ohm*x;
    ohm_d = -Epsilon * F * y/( sqrt(x^2 + y^2) );
    x_new = x + T*x_d;
    y_new = y + T*y_d;
    ohm_new = ohm + T*ohm_d;
    
    plotvar1(n) = F; % input stimulus
    plotvar2(n) = x; % output
    plotvar3(n) = ohm/(2*pi); % frequency
    
    x = x_new;
    y = y_new;
    ohm = ohm_new;
  
end


figure;
plot(t,plotvar1,'r', t,plotvar2,'b'), title('red: input stimulus, blue: output wave as function of time[s]');
grid on
figure;
plot(t, plotvar3), title('blue: output frequency [Hz], as function of time[s]');
grid on
