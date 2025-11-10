classdef (Abstract) CollisionDetectorBase < handle
    % 衝突判定の基底抽象クラス
    
    methods (Abstract)
        [collisions, elapsedTime] = detect(obj, planeGen, rayGen)
    end
    
    methods (Access = protected)
        function inside = pointInPolygon3D(obj, point, vertices, normal)
            % 3D空間での点が多角形内にあるか判定
            % MATLABの組み込み関数inpolygonを使用
            
            if size(vertices, 1) < 3
                inside = false;
                return;
            end
            
            % 最大成分を見つけて射影軸を決定
            [~, maxAxis] = max(abs(normal));
            
            if maxAxis == 1
                axes = [2, 3];  % YZ平面に射影
            elseif maxAxis == 2
                axes = [1, 3];  % XZ平面に射影
            else
                axes = [1, 2];  % XY平面に射影
            end
            
            % 2Dに射影してinpolygonを使用
            point2D = point(axes);
            vertices2D = vertices(:, axes);
            
            % MATLABの組み込み関数を使用（C++実装で高速）
            inside = inpolygon(point2D(1), point2D(2), vertices2D(:,1), vertices2D(:,2));
        end
        
        function intersects = rayPlaneIntersection(obj, rayStart, rayEnd, plane)
            % 単一のレイと平面の交差判定
            rayDir = rayEnd - rayStart;
            
            normal = plane.normal;
            planePoint = plane.vertices(1, :);
            
            denom = dot(normal, rayDir);
            if abs(denom) < 1e-6
                intersects = false;
                return;
            end
            
            t = dot(normal, planePoint - rayStart) / denom;
            if t < 0 || t > 1
                intersects = false;
                return;
            end
            
            % 交点を計算
            intersectionPoint = rayStart + t * rayDir;
            
            % 交点が多角形内にあるか判定
            intersects = obj.pointInPolygon3D(intersectionPoint, plane.vertices, normal);
        end
    end
end