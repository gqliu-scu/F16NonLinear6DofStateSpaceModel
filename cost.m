function [f]=cost(opt);

global X;   %shared only with trim
global gamma;
global turnR;

%global AIL; 
%global EL; 
%global RDR; 
%global THTL;

%Refresh the optimised & constrained parameters while maintaining others:

%refresh the optimization variables
THTL = opt(1);
EL = opt(2);
X(2) = opt(3);
AIL = opt(4);
RDR = opt(5);
X(3) = opt(6);
X(13) = TGEAR(THTL);

%calculate corresponding constrained variables

    %==================================================================
    G=turnR.*X(1)./32.17;           %Page 190
    a=1-G.*tan(X(2)).*sin(X(3));    %Page 190
    b=sin(gamma)./cos(X(3));        %Page 190
    c=1+(G.^2).*(cos(X(3)).^2);     %Page 190

    X(4)=atan((G.*(cos(X(3))./cos(X(2))).*(a-(b.^2))+b.*tan(X(2))...
        .*sqrt(c.*(1-(b.^2))+(G.^2).*(sin(X(3)).^2)))./((a.^2)-(b.^2)...
        .*(1+c.*(tan(X(2)).^2))));

    clear a
    clear b
    clear c
    clear G
    
    a=cos(X(2))*cos(X(3));
    b=sin(X(4))*sin(X(3))+cos(X(4))*sin(X(2))*cos(X(3));
    
    X(5)=atan(((a.*b)+sin(gamma).*sqrt((a.^2)-(sin(gamma).^2)...
        +(b.^2)))./((a.^2)-(sin(gamma).^2)));
        
    %Reversed Kinematic Relations
    %X(7) = (cos(X(6)).*sin(X(5)).*cos(X(4)) + sin(X(6)).*sin(X(4))).*turnR;
    %X(8) = (sin(X(6)).*sin(X(5)).*cos(X(4)) + cos(X(6)).*sin(X(4))).*turnR;
    %X(9) = cos(X(5)).*cos(X(4)).*turnR;
    
    %X(7) = (    -sin(X(5))    ).*turnR;
    %X(8) = (    sin(X(4)).*cos(X(5))    ).*turnR;
    %X(9) = (    cos(X(4)).*cos(X(5))    ).*turnR;
    
    clear a
    clear b
    
   % X(9)=X(7).*tan(X(2));
    %===================================================================
    
%put these into function:
time = 0.0;
[xd]=F16Nonlinear(time,X);

%calculate COST using O( ) coefficients
f=xd(1).^2 + 100.*xd(2).^2 + 100.*xd(3).^2 + 10.*xd(7).^2 + ...
    10.*xd(8).^2 + 10.*xd(9).^2;