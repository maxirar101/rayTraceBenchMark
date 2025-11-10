classdef GPUCollisionDetector < CollisionDetectorBase
    % GPU上でポリゴン内判定を行う実装
    
    methods
        function obj = GPUInpolygonDetector()
            % コンストラクタ
            if gpuDeviceCount == 0
                error('GPU is not available on this system');
            end
        end
        
        function [collisions, elapsedTime] = detect(obj, planeGen, rayGen)
            if gpuDeviceCount == 0
                error('GPU is not available on this system');
            end
            
            numRays = rayGen.numRays;
            numPlanes = planeGen.numPlanes;
            
            % GPUにデータを転送
            startPointsGPU = gpuArray(single(rayGen.startPoints));
            endPointsGPU = gpuArray(single(rayGen.endPoints));
            rayDirsGPU = endPointsGPU - startPointsGPU;
            
            collisions = false(numRays, numPlanes);
            
            tic;
            
            for j = 1:numPlanes
                plane = planeGen.planes(j);
                normalGPU = gpuArray(single(plane.normal));
                planePointGPU = gpuArray(single(plane.vertices(1, :)));
                
                % GPU上で交差判定
                denom = rayDirsGPU * normalGPU';
                validRays = abs(denom) > 1e-6;
                
                if any(validRays)
                    t = gpuArray(zeros(numRays, 1, 'single'));
                    planeVec = planePointGPU - startPointsGPU;
                    t(validRays) = (planeVec(validRays, :) * normalGPU') ./ denom(validRays);
                    
                    validT = validRays & t >= 0 & t <= 1;
                    validIndices = find(gather(validT));
                    
                    if ~isempty(validIndices)
                        % 交点を計算（GPU上）
                        intersectionPointsGPU = startPointsGPU(validIndices, :) + ...
                                              t(validIndices) .* rayDirsGPU(validIndices, :);
                        intersectionPoints = gather(intersectionPointsGPU);
                        
                        % 射影軸を決定
                        [~, maxAxis] = max(abs(plane.normal));
                        if maxAxis == 1
                            axes = [2, 3];
                        elseif maxAxis == 2
                            axes = [1, 3];
                        else
                            axes = [1, 2];
                        end
                        
                        % CPU側でinpolygon（大量の点を一度に処理）
                        points2D = intersectionPoints(:, axes);
                        vertices2D = plane.vertices(:, axes);
                        
                        insideFlags = inpolygon(points2D(:,1), points2D(:,2), ...
                                               vertices2D(:,1), vertices2D(:,2));
                        
                        collisions(validIndices, j) = insideFlags;
                    end
                end
            end
            
            elapsedTime = toc;
        end
    end
end