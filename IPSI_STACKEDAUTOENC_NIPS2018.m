function ipsi_filter=IPSI_STACKEDAUTOENC_FORC(angular_index)
%angular_index is the angle to source re: HMD center (r, theta, phi) where
%theta is horizontal--no elevation phi at this time
vec_degrees_test=(angular_index);powOf2 = 2.^[0:9-1];

input_degree_binary_logical_test=binary2vector(vec_degrees_test,9);



%# do a tiny bit of error-checking
if vec_degrees_test > sum(powOf2)
   error('not enough bits to represent the data')
end



input_degree_binary_numerical_test=double(input_degree_binary_logical_test)';
input_angle_vector_test=input_degree_binary_numerical_test; 
if vec_degrees_test <=90 & vec_degrees_test >0
    input_angle_vector_test(9)=0;
elseif vec_degrees_test >90 & vec_degrees_test <180
    input_angle_vector_test(9)=-1;
end


autoenc2=coder.load('deep_encoder.mat');
autoenc=coder.load('outer_encoder.mat');
net=coder.load('interp_fcnn.mat');  
y_test=net.net(input_angle_vector_test);
reconstructCon_AutoEncode_test2 = decode(autoenc2.autoenc2,y_test);
reconstructCon_AutoEncode_test = decode(autoenc.autoenc,reconstructCon_AutoEncode_test2);
F=(0:1023)'*48000/1024;
B=fir2(512,F(1:(1024/2)+1)/24000,10.^(((reconstructCon_AutoEncode_test(1:(1024/2)+1)))/20));
y=real(ifft(log(abs(fft(B)))));n=512;
w = [1; 2*ones(n/2-1,1); ones(1 - rem(n,2),1); zeros(n/2-1,1)];
ipsi_filter = real(ifft(exp(fft(w'.*y(1:512)))));
figure(1)
plot(ipsi_filter)
grd on
end