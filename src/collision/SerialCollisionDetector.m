classdef SerialCollisionDetector < CollisionDetectorBase
    % シリアル実行（通常のfor文）による衝突判定
    
    methods
        function [collisions, elapsedTime] = detect(obj, planeGen, rayGen)
            % シリアル実行で衝突判定を行う
            % 入力:
            %   planeGen: RandomPlaneGeneratorインスタンス
            %   rayGen: RayGeneratorインスタンス
            % 出力:
            %   collisions: 衝突判定結果 (numRays x numPlanes)
            %   elapsedTime: 実行時間（秒）
            
            numRays = rayGen.numRays;
            numPlanes = planeGen.numPlanes;
            collisions = false(numRays, numPlanes);
            
            tic;
            for i = 1:numRays
                for j = 1:numPlanes
                    collisions(i, j) = obj.rayPlaneIntersection(...
                        rayGen.startPoints(i, :), ...
                        rayGen.endPoints(i, :), ...
                        planeGen.planes(j));
                end
            end
            elapsedTime = toc;
        end
    end
end