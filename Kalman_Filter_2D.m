clc
clear all
close all

data=xlsread('Aeroplane DataPoints.xlsx');

len_data = 0;
for i = 1:500
    x = data(i+6,1);
    if (~isnan(x))
        len_data = len_data + 1;
    else
        break;
    end
end

x_mea_x = zeros(1,len_data-1);
x_mea_y = zeros(1,len_data-1);
v_mea_x = zeros(1,len_data-1);
v_mea_y = zeros(1,len_data-1);
x_prd_x = zeros(1,len_data-1);
x_prd_y = zeros(1,len_data-1);
v_prd_x = zeros(1,len_data-1);
v_prd_y = zeros(1,len_data-1);
x_kalman_x = zeros(1,len_data-1);
x_kalman_y = zeros(1,len_data-1);
v_kalman_x = zeros(1,len_data-1);
v_kalman_y = zeros(1,len_data-1);

del_t = input('Enter the value of delta t.\n');

acc_x = data(1,1);
acc_y = data(1,2);

del_x_obv_x = data(1,6);
del_x_obv_y = data(1,7);

del_v_obv_x = data(3,6);
del_v_obv_y = data(3,7);

R = [del_x_obv_x^2 0 0 0; 0 del_x_obv_y^2 0 0; 0 0 del_v_obv_x^2 0; 0 0 0 del_v_obv_y^2]

del_x_prd_x_init = data(1,4);
del_x_prd_y_init = data(1,5);

del_v_prd_x_init = data(3,4);
del_v_prd_y_init = data(3,5);

A = [1 0 del_t 0; 0 1 0 del_t; 0 0 1 0; 0 0 0 1];
X_k = [data(7,1); data(7,2); data(18,1); data(18,2)];
B = [0.5*del_t^2 0; 0 0.5*del_t^2; del_t 0; 0 del_t];
u_k = [acc_x; acc_y];
P_k_prev = [del_x_prd_x_init^2 0 0 0; 0 del_x_prd_y_init^2 0 0; 0 0 del_v_prd_x_init^2 0; 0 0 0 del_v_prd_y_init^2];
w_k = [0; 0; 0; 0];
Z_k = [0; 0; 0; 0];       %error like delays in reception
C = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1];
H = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1];
I = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1];
Q_k = zeros(4);

for i = 1:len_data-1
    X_k_prd = A*X_k + B*u_k + w_k;
    P_k_prd = A*P_k_prev*A' + Q_k;
    K = P_k_prd*H'*inv(H*P_k_prd*H' + R);
    Y_k_mea = [data(7+i,1); data(7+i,2); data(12+len_data+i,1); data(12+len_data+i,2)];
    Y_k = C*Y_k_mea + Z_k;
    X_k = X_k_prd + K*(Y_k - H*X_k_prd);
    P_k_prev = (I - K*H)*P_k_prd;
    
    x_mea_x(i) = Y_k_mea(1);
    x_mea_y(i) = Y_k_mea(2);
    v_mea_x(i) = Y_k_mea(3);
    v_mea_y(i) = Y_k_mea(4);
    x_prd_x(i) = X_k_prd(1);
    x_prd_y(i) = X_k_prd(2);
    v_prd_x(i) = X_k_prd(3);
    v_prd_y(i) = X_k_prd(4);
    x_kalman_x(i) = X_k(1);
    x_kalman_y(i) = X_k(2);
    v_kalman_x(i) = X_k(3);
    v_kalman_y(i) = X_k(4);
end

figure(1),plot(x_mea_x,x_mea_y,'m--h');
hold on
plot(x_prd_x,x_prd_y,'r-*');
plot(x_kalman_x,x_kalman_y,'b-.o');
hold off
title('Tracking Position of an Aeroplane')
xlabel('Position on X Co-ordinate (in m) -->')
ylabel('Position on Y Co-ordinate (in m) -->')
legend('Measured Position','Predicted Position','Kalman Position','location','northwest');

figure(2),plot(v_mea_x,v_mea_y,'m--h');
hold on
plot(v_prd_x,v_prd_y,'r-*');
plot(v_kalman_x,v_kalman_y,'b-.o');
hold off
title('Tracking Velocity of an Aeroplane')
xlabel('Velocity in X direction (in m/sec) -->')
ylabel('Velocity in Y direction (in m/sec) -->')
legend('Measured Velocity','Predicted Velocity','Kalman Velocity','location','northwest');

filename='Aeroplane DataPoints.xlsx';
xlswrite(filename,x_prd_x',1,'D12');
xlswrite(filename,x_prd_y',1,'E12');
xlswrite(filename,v_prd_x',1,'D23');
xlswrite(filename,v_prd_y',1,'E23');
xlswrite(filename,x_kalman_x',1,'F12');
xlswrite(filename,x_kalman_y',1,'G12');
xlswrite(filename,v_kalman_x',1,'F23');
xlswrite(filename,v_kalman_y',1,'G23');