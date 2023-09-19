
%Programa que simula un experimento psicofisico

%Limites del espacio parametrico y la resolucion de muestreo de las funciones
%Espacio parametrico extendido en dos unidades para
%evitar artefactos de frontera

xini=0-1;  xfin=5+1;  xinc=0.001;
x=[xini:xinc:xfin];

%Parametros de la funcion psicometrica verdadera
npsi=1;                 %1=logistica; 2=Weibull
theta=3;
pi=0.5;
omega=1.5;
lambda=0.1;
gamma=0.15;

%Parametros especificos de la funcion modelo
nmod=1;                  %1->logistica; 2->Weibull
omega2=omega;
lambda2=lambda;
gamma2=gamma;

%Se tabula f0
forma=1;                 %1->uniforme; 2->gaussiana
media=(xfin-xini)/2;     %La funcion a priori este centrada en el espacio parametrico
sx=0.5;
f0=ones(1,length(x)).*priori(x,forma, media,sx);
prior=f0;                %Esta es la funcion a priori para el primer ensayo

%Regla de parada
ntrial=100;              %Se administrara un numero fijo de ntrial ensayos

%Criterio de seleccion de la intensidad en cada ensayo:
crit=2;                  %1->moda; 2-> media

%Comienzan a administrarse ensayos
ngraph=0;
random=csvread('aleatorios.txt');
%random=rand(1,ntrial)
for n=1:ntrial
   level(n)=selec(crit,x,prior);                           %Calcula el nivel del estimulo correspondiente (estimacion de theta a cada ensayo)
   prob=psi(level(n),npsi,theta,omega,lambda,gamma,pi);    %Calcula la probabilidad de exito asociada a level
   model=psi(level(n),nmod,x,omega,lambda,gamma,pi);       %Tabula la funcion modelo, que se usara para calcular la funcion de verosimilitud:
                                                           %likelihood= model.^r .* (1-model).^(1-r);
   if random(n) <= prob
      r=1;                                                 %Exito
      likelihood= model;
   else 
      r=0;                                                 %Fracaso
      likelihood=(1-model);
   end;
   posterior=(prior.*likelihood)./max(prior);                    %Calcula la funcion a posteriori impropia y la reescala
   %posterior=(prior.*likelihood);   %Calcula la funcion a posteriori
   escribe=['Ensayo: ',num2str(n),    ';   Nivel del estimulo = ', num2str(level(n)),';   Probabilidad de exito = ', num2str(prob),';   Respuesta = ', int2str(r)];
   disp (escribe)
   if n<10, figure (1), plot (x,likelihood, 'r',x,prior, 'b',x,posterior,'m'), xlabel('Valor del umbral, \theta'); ylabel('Densidad de probabilidad'),pause, end; %el pause es lo q hace q tengamos q ir dandole al enter
   if n<=9
       figure (2)
       subplot (3,3,n)
       plot (x,likelihood, 'r',x,prior, 'b',x,posterior,'m');
       title (['ensayo ' int2str(n) '  respuesta: ' int2str(r)]);
    elseif n>ntrial-9 
       figure (3)
       ngraph=ngraph+1;
       subplot (3,3,ngraph)
       plot (x,likelihood, 'r',x,prior, 'b',x,posterior,'m');
       title (['ensayo ' int2str(n) '  respuesta: ' int2str(r)]);
   end
   prior=posterior;                                        %La funcion a posteriori de un ensayo pasa a ser la funcion a priori del ensayo siguiente
end

%Terminan de administrarse ensayos
figure (4)
the=ones(1,length(level))*theta;
plot (level, 'k o -'); hold; plot (the, 'k :'); hold;
xlabel('N� de ensayo'); ylabel('Nivel del estimulo')

estimate=selec(crit,x,prior);                              %Una vez que se han administrado todos los ensayos se calcula la estimacion de theta
residual=estimate-theta;
escribe=['Estimacion del umbral: ',num2str(estimate),    ';   Residuo = ', num2str(residual)];
disp(escribe)
clear