clc
clear all
close all

data=xlsread('Temp DataPoints.xlsx');
temp_mea=data(2:length(data),1);

temp_est=zeros(length(temp_mea),1);

initial_est=data(1,5);
initial_err_est=data(1,6);
num_particles=[20, 50, 100, 200, 500, 1000, 2000]; %%various number of particles
for l=1:length(num_particles) %% loop for above

a = -10;
b = 60;
par = linspace(a,b,num_particles(l));
var=0.5;
for k=1:20 %% different readings for same number of particles
%% SIR paricle filter algorithm  
%%initialize particles
for i=1:num_particles(l) 
    w(i)=1/num_particles(l);
end
for j=1:length(temp_mea)
    for i=1:num_particles(l)
        w(i)=w(i)*exp(-0.5*((temp_mea(j)-par(i))^2)/(var^2))/(var*sqrt(2*pi));
    end
%%normalize weights
%     norm=0;
%     for i=1:num_particles(l)
%         norm=norm+w(i);
%     end
%     for i=1:num_particles(l)
%         w(i)=w(i)/norm;
%     end
%%estimated particle
    [m,ind]=max(w);
    temp_est(j)=par(ind);
%%resampling
%%computing number of particles effective
    neff1=0;
    for i=1:num_particles(l)
        neff1=neff1+(w(i)^2);
    end
    neff=1/neff1;
    if neff<num_particles(l)/10
        for i=1:num_particles(l)
            w(i)=1/num_particles(l);
            par(i)=normrnd(temp_est(j),5); %randomly distributed
        end 
%       par = linspace(temp_est(j)-10,temp_est(j)+10,num_particles(l)); % linearly distributed
    end
%%making particles;
end
%%mse 
temp_act=13;
mse=0;
for i=1:length(temp_est)
    mse = mse+ (temp_est(i)-temp_act)^2;
end
mse1(k)=mse;
end
n=0;
for k=1:20
    n=n+mse1(k);
end
n1(l)=n/20;
 end
%%graph plots
x_axis=1:length(temp_mea);
plot(x_axis,temp_mea,'r-*');
ylim([10 15]);
hold on
plot(x_axis,temp_est,'b-.o');
hold off
title('Smoothing Temperature using SIR Particle Filter, Number of particles = 20')
xlabel('# of Iteration -->')
ylabel('Temperature (in Celsius) -->')
legend('Measured Temperatute','Estimated Temperature');

%filename='Temp DataPoints1.xlsx';
%%xlswrite(filename,KG,1,'D5');
%xlswrite(filename,temp_est,1,'E5');
%%xlswrite(filename,err_est,1,'F5');