global X;   %shared only with cost
global gamma;
global turnR;

global AIL; 
global EL; 
global RDR;
global THTL;

global XCG;

RTOD=57.29577951;

%1)Defaults and Estimates for Variables---------------------------------

%                                       Units       initial     R.O.C.

THTL=0.1;EL=-0.5; AIL=0.0; RDR=0.0;    %(%)(rad)x3  optimised*  ------

XCG=0.25;                              %(ft)        selected    ------

X(1)=700;  %True Airspeed               (ft/s)      selected    Zero
X(2)=0.0;  %Angle of Attack             (rad)       optimised*  Zero
X(3)=0.0;  %Angle of Sideslip           (rad)       optimised*  Zero
X(4)=0.0;  %Roll (BANK) Angle           (rad)       constrained ~RR=0
X(5)=0.0;  %Pitch (ATTITUDE) Angle      (rad)       constrained ~PR=0
X(6)=0.0;  %Yaw (AZIMOUTHAL) Angle      (rad)       free        TR=Selected
X(7)=0.0;  %Roll Rate                   (rad/s)     constrained Zero
X(8)=0.0;  %Pitch Rate                  (rad/s)     constrained Zero
X(9)=0.0;  %Yaw Rate                    (rad/s)     constrained Zero
X(10)=0.0; %Earth Cartesian x coord     (ft)        free        irrelevant
X(11)=0.0; %Earth Cartesian y coord     (ft)        free        irrelevant
X(12)=0.0; %Earth Cartesian z coord     (ft)        selected    ~zero
X(13)=0.0; %Power                       (J/s?)      constrained ~zero

%2)Desired State Variables----------------------------------------------
    
    disp(['=== Turn to p197 ===']);
    XCG=input('Enter position of Centre of Mass {0.35(cbar)}: ');
    X(12)=input('Enter Altitude {0(ft)}: ');
    X(1)=input('Enter True Airspeed {502(ft/s)}: ');
    gamma=input('Enter Desired Climb Angle {0(rad)}: ');
    turnR=input('Enter Desired Turn Rate {0(rad/s)}: ');
    clc
are_you_done=0;
while (are_you_done==0)
    X(2)=input('Enter Angle of Attack estimate {0.03691(rad)}: ');
    X(3)=input('Enter Sideslip Angle estimate {-4e-9(rad)}: ');
    THTL=input('Enter Throttle setting estimate {0.1385(%)}: ');
    EL=input('Enter Elevator Deflection estimate {-0.7588(rad)}: ');
    AIL=input('Enter Aileron Deflection estimate {-1.2e-7(rad)}: ');
    RDR=input('Enter Rudder Deflection estimate {6.2e-7(rad)}: ');
    clc
    disp(['Please Wait...']);

%3)Apply Constraints----------------------------------------------------
    
    %This must also be done inside the cost function [see wilko notebook]
    
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
    
    X(5)=X(2)+gamma;
    
    clear a
    clear b

    %Reversed Kinematic Relations
    %X(7) = (    -sin(X(5))    ).*turnR;
    %X(8) = (    sin(X(4)).*cos(X(5))    ).*turnR;
    %X(9) = (    cos(X(4)).*cos(X(5))    ).*turnR;
    
 %   X(9)=X(7).*tan(X(2));
    
    X(13) = TGEAR(THTL);
    %===================================================================

%4)Prepare Optimisation Vector------------------------------------------

S=zeros(6,1);   %build a vector from the optimisation variables

S(1)=THTL;  LB(1)=0;        UB(2)=100;      %throttle setting
S(2)=EL;    LB(2)=-pi/3;    UB(2)=+pi/3;    %elevator deflection
S(3)=X(2);  LB(3)=-pi/3;    UB(3)=+pi/3;    %Angle of Attack
S(4)=AIL;   LB(4)=-pi/3;    UB(4)=+pi/3;    %aileron deflection
S(5)=RDR;   LB(5)=-pi/3;    UB(5)=+pi/3;    %rudder deflection
S(6)=X(3);  LB(6)=-pi/3;    UB(6)=+pi/3;    %Angle of Sideslip

options = optimset('TolX',0.0,'MaxFunEvals',1000,'Display','iter');

%[S, fval]=fminsearch(@cost,S,options);
[S, fval]=PSO('cost',S,LB,UB);

THTL=S(1);      %throttle setting
EL=S(2);        %elevator deflection
X(2)=S(3);      %Angle of Attack
AIL=S(4);       %aileron deflection
RDR=S(5);       %rudder deflection
X(3)=S(6);      %Angle of Sideslip

are_you_done=input('is this acceptable? {Y=1,N=0}');
end

disp('Throttle      Elevator        Ailerons        Rudder          ');
disp([num2str(THTL),'       ',num2str(EL),'         ',num2str(AIL),'        ',num2str(RDR)])