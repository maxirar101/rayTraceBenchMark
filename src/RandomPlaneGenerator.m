classdef RandomPlaneGenerator < handle
    % 任意の向きの三次元有限平面（多角形）を生成するクラス
    
    properties
        planes      % 平面データを格納する構造体配列
        numPlanes   % 平面の数
    end
    
    methods
        function obj = RandomPlaneGenerator(numPlanes, varargin)
            % コンストラクタ
            % numPlanes: 生成する平面の数
            % varargin: オプション (verticesRange, numVertices)
            
            p = inputParser;
            addRequired(p, 'numPlanes', @(x) isnumeric(x) && x > 0);
            addParameter(p, 'verticesRange', 10, @isnumeric);
            addParameter(p, 'numVerticesRange', [3, 8], @(x) isnumeric(x) && length(x) == 2);
            parse(p, numPlanes, varargin{:});
            
            obj.numPlanes = p.Results.numPlanes;
            obj.generatePlanes(p.Results.verticesRange, p.Results.numVerticesRange);
        end
        
        function generatePlanes(obj, verticesRange, numVerticesRange)
            % 平面を生成
            obj.planes = struct('vertices', {}, 'normal', {}, 'center', {}, 'bounds', {});
            
            for i = 1:obj.numPlanes
                % 頂点数をランダムに決定
                numVertices = randi(numVerticesRange);
                
                % ランダムな中心点を生成
                center = (rand(1, 3) - 0.5) * verticesRange * 2;
                
                % ランダムな法線ベクトルを生成
                normal = randn(1, 3);
                normal = normal / norm(normal);
                
                % 法線に垂直な2つのベクトルを生成
                if abs(normal(3)) < 0.9
                    v1 = cross(normal, [0, 0, 1]);
                else
                    v1 = cross(normal, [1, 0, 0]);
                end
                v1 = v1 / norm(v1);
                v2 = cross(normal, v1);
                v2 = v2 / norm(v2);
                
                % 多角形の頂点を生成
                angles = sort(rand(numVertices, 1) * 2 * pi);
                radius = rand(numVertices, 1) * verticesRange/3 + verticesRange/6;
                
                vertices = zeros(numVertices, 3);
                for j = 1:numVertices
                    localCoord = radius(j) * [cos(angles(j)), sin(angles(j))];
                    vertices(j, :) = center + localCoord(1) * v1 + localCoord(2) * v2;
                end
                
                % バウンディングボックスを計算
                minBound = min(vertices, [], 1);
                maxBound = max(vertices, [], 1);
                
                % 構造体に格納
                obj.planes(i).vertices = vertices;
                obj.planes(i).normal = normal;
                obj.planes(i).center = center;
                obj.planes(i).bounds = [minBound; maxBound];
            end
        end
        
        function visualize(obj, indices)
            % 平面を可視化
            if nargin < 2
                indices = 1:min(10, obj.numPlanes);
            end
            
            figure;
            hold on;
            colors = lines(length(indices));
            
            for idx = 1:length(indices)
                i = indices(idx);
                vertices = obj.planes(i).vertices;
                fill3(vertices(:,1), vertices(:,2), vertices(:,3), ...
                      colors(idx,:), 'FaceAlpha', 0.5, 'EdgeColor', 'k');
            end
            
            xlabel('X'); ylabel('Y'); zlabel('Z');
            title(sprintf('3D Planes (showing %d of %d)', length(indices), obj.numPlanes));
            grid on;
            axis equal;
            view(3);
        end
    end
end