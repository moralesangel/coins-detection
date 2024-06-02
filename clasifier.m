function [estimatedCoin, dif1] = clasifier(coinToClasify, numCoins, diameters, COINS_RELATIONS_A, boundingBox, coinsImg)
    COINS_AMOUNT = 8;
    yest = zeros(1, COINS_AMOUNT);
    for k=1:numCoins
        relation = ((diameters(coinToClasify)/2)^2*pi)/((diameters(k)/2)^2*pi);
        inf = 0.99;
        sup = 1 + 1 - inf;
        
        if k ~= coinToClasify
            for i=1:COINS_AMOUNT
                for j=1:COINS_AMOUNT
                    if COINS_RELATIONS_A(i, j) * inf <= relation && relation <= COINS_RELATIONS_A(i, j) * sup
                        yest(j) = yest(j)+relation/(COINS_RELATIONS_A(i, j) * inf)+(COINS_RELATIONS_A(i, j) * sup)/relation;
                    end
                end
            end
        end
    end

    % Calcula las coordenadas del cuadro delimitador en formato [x, y, ancho, alto]
    x = round(boundingBox(1));
    y = round(boundingBox(2));
    ancho = round(boundingBox(3));
    alto = round(boundingBox(4));

    % Recorta la moneda de la imagen original
    moneda_recortada = imcrop(coinsImg, [x, y, ancho, alto]);

    figure;
    colors = 'rgb';
    maxColor = zeros(1, 3);
    for j=1:3
         histograma = imhist(moneda_recortada(:, :, j));
        [~, maxColor(j)] = max(histograma(1:248));
        subplot(1, 2, 2);plot((0:255), histograma, colors(j));hold on; 
        title('Histograma de la imagen');
        xlim([0, 255]);
        if j == 1
            ylim([0, max(histograma)]);
        end
        xlabel('Tono de color');
        ylabel('Frecuencia');
        subplot(1, 2, 1);imshow(moneda_recortada);
    end
    hold off;
    dif1 = abs(maxColor(1) - maxColor(2));
    dif2 = abs(maxColor(2) - maxColor(3));
    if dif1 < 30
        if dif2 < 10
            title('Moneda de 1 euro');
            yest(6) = yest(6) + 5;
        else
            title('Moneda dorada');
            yest(4) = yest(4) + 5;
            yest(5) = yest(5) + 5;
            yest(7) = yest(7) + 5;
        end
    else
        title('Moneda de bronce');
        yest(1) = yest(1) + 5;
        yest(2) = yest(2) + 5;
        yest(3) = yest(3) + 5;
    end
    %coinToClasify
    %yest
    [~, estimatedCoin] = max(yest);
    

end

