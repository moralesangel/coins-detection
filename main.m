%% Cleaning workspace
close all, clear, clc

%% Get image and convert it to gray
coins = imread("coins.jpg");
coinsBlurred = imgaussfilt(coins, 4);
coinsGray = rgb2gray(coins);
figure;imshow(coins);

%% Histograma
% figure;
% histograma = imhist(coinsGray);
% bar(histograma);
% title('Histograma de la imagen en blanco y negro');
% xlabel('Tono de gris');
% ylabel('Frecuencia');

%% Blurring image to get rid of noise
% Binarization without blurring
coinsBinary = imbinarize(coinsGray);
figure;imshow(imbinarize(coinsGray));
% Blurring before binarization
coinsGrayBlurred = imgaussfilt(coinsGray, 4);
coinsBinaryBlurred = imbinarize(coinsGrayBlurred);

%% PLOTS to show importance of blurring
% figure;imshow(coins);
% figure;
% subplot(2, 2, 1);imshow(coinsGray);
% subplot(2, 2, 2);imshow(coinsGrayBlurred);
% subplot(2, 2, 3);imshow(coinsBinary);
% subplot(2, 2, 4);imshow(coinsBinaryBlurred);

%% Detect circles
bordes = edge(coinsBinaryBlurred, 'canny');
bordes = imfill(bordes, 'holes');
labels = bwlabel(bordes);
properties = regionprops(coinsBinaryBlurred);

figure;imshow(coinsBinaryBlurred);
figure;imshow(label2rgb(labels));
% Get circles info
numCoins = length(properties);
centers = zeros(numCoins, 2);
radios = zeros(numCoins, 1);
boundingBox = zeros(numCoins, 4);
for i=1:numCoins
    centers(i, :) = properties(i).Centroid;
    radios(i) = (properties(i).Area/pi)^(1/2);
    boundingBox(i, :) = properties(i).BoundingBox;
end
diameters = radios*2;

% Encuentra el índice de orden ascendente de los diámetros
[~, orden] = sort(diameters);
centers = centers(orden, :);
radios = radios(orden);
diameters = diameters(orden);
boundingBox = boundingBox(orden, :);

% Draw circles
viscircles(centers, radios,'EdgeColor','k');
for i=1:numCoins
    txt = [num2str(i)];
    text(centers(i, 1), centers(i, 2),txt);
end

%% Relation between coins
COINS_AMOUNT = 8;
COINS_DIAMETERS = [16.26, 18.75, 21.25, 19.75, 22.25, 24.25, 23.25, 25.75];
COINS_VALUE = [1, 2, 5, 10, 20, 50, 100, 200];
COINS_RELATIONS_A = zeros(COINS_AMOUNT, COINS_AMOUNT);

for i=1:COINS_AMOUNT
    for j=1:COINS_AMOUNT
        COINS_RELATIONS_A(i, j) = ((COINS_DIAMETERS(j)/2)^2*pi)/((COINS_DIAMETERS(i)/2)^2*pi);
    end
end
    

%% Clasificar 2 monedas
y = [1, 2, 4, 3, 5, 6]; % coins
%y = [1, 1, 2, 4, 4, 3, 3, 5, 5, 5]; % coins2
%y = [1, 1, 1, 1, 2, 2, 2, 2, 4, 4, 3, 5, 5, 3, 5]; % coins3
%y = [2, 2, 4, 3, 5, 5]; % coins4
error = 0;
estimatedTotal = 0;
difs = zeros(1, length(y));
for coinToClasify=1:length(y)
    [estimatedCoin, dif] = clasifier(coinToClasify, numCoins, diameters, COINS_RELATIONS_A, boundingBox(coinToClasify, :), coins);
    switch estimatedCoin
        case 1
            disp('1 centimo');
            estimatedTotal = estimatedTotal + 1;
        case 2
            disp('2 centimos');
            estimatedTotal = estimatedTotal + 2;
        case 3
            disp('5 centimos');
            estimatedTotal = estimatedTotal + 5;
        case 4
            disp('10 centimos');
            estimatedTotal = estimatedTotal + 10;
        case 5
            disp('20 centimos');
            estimatedTotal = estimatedTotal + 20;
        case 6
            disp('1 euro');
            estimatedTotal = estimatedTotal + 100;
        case 7
            disp('50 centimos');
            estimatedTotal = estimatedTotal + 50;
        case 8
            disp('2 euros');
            estimatedTotal = estimatedTotal + 200;
    end
    
    if estimatedCoin ~= y(coinToClasify)
        error = error + 1;
    end
    
    difs(coinToClasify) = dif;

end
error
disp(['EL total estimado es: ', num2str(estimatedTotal), ' centimos'])

%figure;plot(difs, diameters, 'o');















