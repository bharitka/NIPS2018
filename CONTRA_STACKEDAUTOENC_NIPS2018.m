function contra_filter_ITD=CONTRA_STACKEDAUTOENC_NIPS2018(angular_index)
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


autoenc2_contra=load('deep_encoder_contra.mat');
autoenc_contra=load('outer_encoder_contra.mat');
net_contra=load('interp_fcnn_contra.mat');  
y_test_contra=net_contra.net(input_angle_vector_test);
reconstructCon_AutoEncode_test2_contra = decode(autoenc2_contra.autoenc2,y_test_contra);
reconstructCon_AutoEncode_test_contra = decode(autoenc_contra.autoenc,reconstructCon_AutoEncode_test2_contra);
F=(0:1023)'*48000/1024;
B_contra=fir2(512,F(1:(1024/2)+1)/24000,10.^(((reconstructCon_AutoEncode_test_contra(1:(1024/2)+1)))/20));
y_contra=real(ifft(log(abs(fft(B_contra)))));n=512;
w = [1; 2*ones(n/2-1,1); ones(1 - rem(n,2),1); zeros(n/2-1,1)];
contra_filter_minphase = real(ifft(exp(fft(w'.*y_contra(1:512)))));
p=[   5.20557027280039e-19
     -3.84635204053778e-16
      1.14594023241818e-13
     -1.75593018901975e-11
      1.46718095752928e-09
     -6.62013402734264e-08
      1.49828787471483e-06
      -6.3041865355898e-06
      2.31015678721856e-05
];
itd_samples=round(polyval(p,angular_index)*48000);
contra_filter_ITD=filter([zeros(max(itd_samples-1,1),1);1],1,contra_filter_minphase);
figure(2)
plot(contra_filter)
grid on
end