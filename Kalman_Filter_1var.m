clc
clear all
close all

data=xlsread('Temp DataPoints.xlsx');
temp_mea=data(2:length(data),1);
err_mea=data(2:length(data),2);

actual_temp=13;

temp_est=zeros(length(temp_mea),1);
err_est=zeros(length(temp_mea),1);
KG=zeros(length(temp_mea),1);

initial_est=data(1,5);
initial_err_est=data(1,6);

for i=1:length(temp_mea)
    if(i==1)
        KG(i)=initial_err_est/(initial_err_est + err_mea(i));
        temp_est(i)=initial_est + KG(i)*(temp_mea(i)-initial_est);
        err_est(i)=(1-KG(i))*initial_err_est;
    else
        KG(i)=err_est(i-1)/(err_est(i-1) + err_mea(i));
        temp_est(i)=temp_est(i-1) + KG(i)*(temp_mea(i)-temp_est(i-1));
        err_est(i)=(1-KG(i))*err_est(i-1);
    end
end

x_axis=1:length(temp_mea);
act_temp=actual_temp*ones(length(temp_mea),1);
plot(x_axis,temp_mea,'r-*');
ylim([10 20]);
hold on
plot(x_axis,act_temp,'m');
plot(x_axis,temp_est,'b-.o');
hold off
title('Smoothing Temperature using Kalman Filter')
xlabel('# of Iteration -->')
ylabel('Temperature (in Celsius) -->')
legend('Measured Temperatute','Actual Temperature','Estimated Temperature');

mse=mean((act_temp-temp_est).^2)

filename='Temp DataPoints.xlsx';
xlswrite(filename,KG,1,'D5');
xlswrite(filename,temp_est,1,'E5');
xlswrite(filename,err_est,1,'F5');