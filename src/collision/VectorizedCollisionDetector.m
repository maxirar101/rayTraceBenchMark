classdef VectorizedCollisionDetector < CollisionDetectorBase
    % ベクトル化による衝突判定
    
    methods
        function obj = VectorizedInpolygonDetector()
            % コンストラクタ
        end
        
        function [collisions, elapsedTime] = detect(obj, planeGen, rayGen)
            numRays = rayGen.numRays;
            numPlanes = planeGen.numPlanes;
            collisions = false(numRays, numPlanes);
            
            % レイの方向を事前計算
            rayDirs = rayGen.endPoints - rayGen.startPoints;
            
            tic;
            
            for j = 1:numPlanes
                plane = planeGen.planes(j);
                normal = plane.normal;
                planePoint = plane.vertices(1, :);
                
                % すべてのレイに対して交差パラメータtを計算（ベクトル化）
                denom = rayDirs * normal';
                validRays = abs(denom) > 1e-6;
                
                if any(validRays)
                    t = zeros(numRays, 1);
                    planeVec = planePoint - rayGen.startPoints;
                    t(validRays) = (planeVec(validRays, :) * normal') ./ denom(validRays);
                    
                    % 有効な交差のインデックス
                    validT = validRays & t >= 0 & t <= 1;
                    validIndices = find(validT);
                    
                    if ~isempty(validIndices)
                        % 交点を一括計算
                        intersectionPoints = rayGen.startPoints(validIndices, :) + ...
                                           t(validIndices) .* rayDirs(validIndices, :);
                        
                        % 射影軸を決定
                        [~, maxAxis] = max(abs(normal));
                        if maxAxis == 1
                            axes = [2, 3];
                        elseif maxAxis == 2
                            axes = [1, 3];
                        else
                            axes = [1, 2];
                        end
                        
                        % 2D射影
                        points2D = intersectionPoints(:, axes);
                        vertices2D = plane.vertices(:, axes);
                        
                        % inpolygonをベクトル化して呼び出し
                        insideFlags = inpolygon(points2D(:,1), points2D(:,2), ...
                                               vertices2D(:,1), vertices2D(:,2));
                        
                        % 結果を格納
                        collisions(validIndices, j) = insideFlags;
                    end
                end
            end
            
            elapsedTime = toc;
        end
    end
end