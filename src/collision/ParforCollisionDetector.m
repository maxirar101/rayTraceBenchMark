classdef ParforCollisionDetector < CollisionDetectorBase
    % 並列実行（parfor）による衝突判定
    
    methods
        function [collisions, elapsedTime] = detect(obj, planeGen, rayGen)
            % parforで衝突判定を行う
            % 入力:
            %   planeGen: RandomPlaneGeneratorインスタンス
            %   rayGen: RayGeneratorインスタンス
            % 出力:
            %   collisions: 衝突判定結果 (numRays x numPlanes)
            %   elapsedTime: 実行時間（秒）
            
            numRays = rayGen.numRays;
            numPlanes = planeGen.numPlanes;
            collisions = false(numRays, numPlanes);
            
            % ローカル変数にコピー（parforのために必要）
            startPoints = rayGen.startPoints;
            endPoints = rayGen.endPoints;
            planes = planeGen.planes;
            
            tic;
            parfor i = 1:numRays
                rayCollisions = false(1, numPlanes);
                for j = 1:numPlanes
                    rayCollisions(j) = obj.rayPlaneIntersection(...
                        startPoints(i, :), ...
                        endPoints(i, :), ...
                        planes(j));
                end
                collisions(i, :) = rayCollisions;
            end
            elapsedTime = toc;
        end
    end
end