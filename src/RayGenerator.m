classdef RayGenerator < handle
    % 複数の始点・終点（レイ）を生成するクラス
    
    properties
        startPoints   % 始点の座標 (N x 3)
        endPoints     % 終点の座標 (N x 3)
        numRays       % レイの数
    end
    
    methods
        function obj = RayGenerator(numRays, varargin)
            % コンストラクタ
            % numRays: 生成するレイの数
            % varargin: オプション (range, lengthRange)
            
            p = inputParser;
            addRequired(p, 'numRays', @(x) isnumeric(x) && x > 0);
            addParameter(p, 'range', 20, @isnumeric);
            addParameter(p, 'lengthRange', [5, 30], @(x) isnumeric(x) && length(x) == 2);
            parse(p, numRays, varargin{:});
            
            obj.numRays = p.Results.numRays;
            obj.generateRays(p.Results.range, p.Results.lengthRange);
        end
        
        function generateRays(obj, range, lengthRange)
            % レイを生成
            
            % ランダムな始点を生成
            obj.startPoints = (rand(obj.numRays, 3) - 0.5) * range * 2;
            
            % ランダムな方向と長さでレイを生成
            directions = randn(obj.numRays, 3);
            directions = directions ./ vecnorm(directions, 2, 2);
            
            lengths = rand(obj.numRays, 1) * (lengthRange(2) - lengthRange(1)) + lengthRange(1);
            
            obj.endPoints = obj.startPoints + directions .* lengths;
        end
        
        function visualize(obj, indices)
            % レイを可視化
            if nargin < 2
                indices = 1:min(50, obj.numRays);
            end
            
            figure;
            hold on;
            
            for i = indices
                plot3([obj.startPoints(i,1), obj.endPoints(i,1)], ...
                      [obj.startPoints(i,2), obj.endPoints(i,2)], ...
                      [obj.startPoints(i,3), obj.endPoints(i,3)], ...
                      'b-', 'LineWidth', 1);
                plot3(obj.startPoints(i,1), obj.startPoints(i,2), obj.startPoints(i,3), ...
                      'go', 'MarkerSize', 5, 'MarkerFaceColor', 'g');
                plot3(obj.endPoints(i,1), obj.endPoints(i,2), obj.endPoints(i,3), ...
                      'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
            end
            
            xlabel('X'); ylabel('Y'); zlabel('Z');
            title(sprintf('Rays (showing %d of %d)', length(indices), obj.numRays));
            grid on;
            axis equal;
            view(3);
        end
    end
end