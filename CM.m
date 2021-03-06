%works out the aerodynamic pitching moment coefficient 

function [output] = CM(ALPHA,EL)

data=...
[0.205, 0.168, 0.186, 0.196, 0.213, 0.251, 0.245, 0.238, 0.252, 0.231, 0.198, 0.192;...
 0.081, 0.077, 0.107, 0.110, 0.110, 0.141, 0.127, 0.119, 0.133, 0.108, 0.081, 0.093;...
-0.046,-0.020,-0.009,-0.005,-0.006, 0.010, 0.006,-0.001,-0.014, 0.000,-0.013, 0.032;...
-0.174,-0.145,-0.121,-0.127,-0.129,-0.102,-0.097,-0.113,-0.087,-0.084,-0.069,-0.006;...
-0.259,-0.202,-0.184,-0.193,-0.199,-0.150,-0.160,-0.167,-0.104,-0.076,-0.041,-0.005];

%x=linspace(0.2.*(-2),0.2.*9,12);
%y=linspace(-2./12,2./12,5);
%[x,y]=meshgrid(x,y);
%surf(x,y,data)

S=0.2.*ALPHA;       %Switch from ALPHA to horizontal lookup parameter
K=int8(S);          %find index of the nearest data point

if (K<=-2)           %find index of the nearest INNER data point (K)
    K=-1;            % X 0 0 0 0 0 0 0 0 0 0 X
elseif (K>=9)
    K=8;
end

DA=S-single(K);     %find direction to the other neighbouring data point
L=K+int8(sign(DA)); %find index of the latter data point (L)

%--------------------------------------------------------------------------

S=EL./12.0;         %Switch from EL to vertical lookup parameter
M=int8(S);          %find index of the nearest data point

if (M<=-2)          %find index of the nearest INNER data point (M)
    M=-1;
elseif (M>=2)
    M=1;
end

DE=S-single(M);     %find direction to the other neighbouring data point
N=M+int8(sign(DE)); %find index of the latter data point (N)

%--------------------------------------------------------------------------

T=data(M+3,K+3);         %find the nearest CFx inner data point
U=data(N+3,K+3);         %find the next nearest CFx inner data point

V= T + abs(DA).*(data(M+3,L+3) - T);   %linear interpolate between (K L) on (M)
W= U + abs(DA).*(data(N+3,L+3) - U);   %linear interpolate between (K L) on (N)

output=V + (W-V).*abs(DE);   %linear interpolate between (V W)