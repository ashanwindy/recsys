%%
[train, test] = readData('/home/dlian/data/subcheckin/',1);
[U,V] = piccf(train>0, 'max_iter',10);
[U1,V1] = iccf(train>0, 'max_iter',10);
%% training beijing data

data = readContent('/home/dlian/data/checkin/Beijing/data.txt');
[M, N] = size(data);
item_grid = readContent('/home/dlian/data/checkin/Beijing/item_grids_17.txt', 'nrows', N);
sigma = -1/log(1e-3);
item_grid(item_grid>0) = exp(-item_grid(item_grid>0).^2./sigma);
[train, test] = split_matrix(+(data>0), 'un', 0.8);

alg = @(varargin) item_recommend(@(mat) iccf(mat, 'Y', item_grid, 'K', 50, 'max_iter', 20, varargin{:}), train, 'test', test, 'topk', 100);
metric_func = @(metric) metric.recall(1,end);
[para, metric2] = hyperp_search(alg, metric_func, 'reg_i', [1000, 5000, 10000, 50000, 100000]);


%sensitive_analysis('/home/dlian/data/checkin/Beijing', 30, 50, 50000, 10)
alpha = 30; K = 50; reg_i = 50000; reg_1 = 10;

[~, ~, metric_train_wals, times_train_wals] = hyperp_search(...
    @(varargin) item_recommend(@iccf, +(data>0), 'test_ratio', 0.2, 'alpha', alpha, 'K', K, varargin{:}), ...
    @(metric) metric.recall(1,end), 'train_ratio', (0.2:0.2:1)*0.8);
[K_wals, ~, metric_K_wals, times_K_wals] = hyperp_search(...
    @(varargin) item_recommend(@iccf, +(data>0), 'test_ratio', 0.2, 'alpha', alpha, varargin{:}), ...
    @(metric) metric.recall(1,end), 'K', 50:50:300);


[~, ~, metric_train_iccf, times_train_iccf] = hyperp_search(...
    @(varargin) item_recommend(@iccf, +(data>0), 'test_ratio', 0.2, 'alpha', alpha, 'K', K, 'Y', item_grid, 'reg_i', reg_i, varargin{:}), ...
    @(metric) metric.recall(1,end), 'train_ratio', (0.2:0.2:1)*0.8);
[K_iccf, ~, metric_K_iccf, times_K_iccf] = hyperp_search(...
    @(varargin) item_recommend(@iccf, +(data>0), 'test_ratio', 0.2, 'alpha', alpha, 'Y', item_grid, 'reg_i', reg_i, varargin{:}), ...
    @(metric) metric.recall(1,end), 'K', 50:50:300);

[~, ~, metric_train_piccf, times_train_piccf] = hyperp_search(...
    @(varargin) item_recommend(@piccf, +(data>0), 'test_ratio', 0.2, 'alpha', alpha, 'K', K, 'Y', item_grid, 'reg_i', reg_i, varargin{:}), ...
    @(metric) metric.recall(1,end), 'train_ratio', (0.2:0.2:1)*0.8);
[K_piccf, ~, metric_K_piccf, times_K_piccf] = hyperp_search(...
    @(varargin) item_recommend(@piccf, +(data>0), 'test_ratio', 0.2, 'alpha', alpha, 'Y', item_grid, 'reg_i', reg_i, varargin{:}), ...
    @(metric) metric.recall(1,end), 'K', 50:50:300);

[~, ~, metric_train_geomf, times_train_geomf] = hyperp_search(...
    @(varargin) item_recommend(@geomf, +(data>0), 'test_ratio', 0.2, 'alpha', alpha, 'K', K, 'Y', item_grid, 'reg_1', reg_1, varargin{:}), ...
    @(metric) metric.recall(1,end), 'train_ratio', (0.2:0.2:1)*0.8);
[K_geomf, ~, metric_K_geomf, times_K_geomf] = hyperp_search(...
    @(varargin) item_recommend(@geomf, +(data>0), 'test_ratio', 0.2, 'alpha', alpha, 'Y', item_grid, 'reg_1', reg_1, varargin{:}), ...
    @(metric) metric.recall(1,end), 'K', 50:50:300);

save('/home/dlian/data/checkin/Beijing/sensitive.mat', 'metric_K_geomf', 'times_K_geomf','K_geomf','metric_train_geomf','times_train_geomf', '-append');



%metric_cv = item_recommend(@(mat) iccf(mat, 'K', 50, 'max_iter', 20), +(data>0), 'folds', 5);
%metric_spatial_cv = item_recommend(@(mat) iccf(mat, 'Y', item_grid, 'K', 50, 'max_iter', 20, 'reg_i', 50000), +(data>0), 'folds', 5);
%save('/home/dlian/data/checkin/Beijing/iccf.result.mat', 'metric_cv', 'metric_spatial_cv');

%metric_cv100 = item_recommend(@(mat) iccf(mat, 'K', 100, 'max_iter', 20), +(data>0), 'folds', 5);
%metric_spatial_cv100 = item_recommend(@(mat) iccf(mat, 'Y', item_grid, 'K', 100, 'max_iter', 20, 'reg_i', 50000), +(data>0), 'folds', 5);

%save('/home/dlian/data/checkin/Beijing/iccf.result.mat', 'metric_cv', 'metric_spatial_cv');

%metric_geo_cv = item_recommend(@(mat) geomf(mat, 'K', 50, 'max_iter', 10, 'reg_1', 10, 'Y', item_grid), +(data>0), 'folds', 5);
%metric_geo_cv100 = item_recommend(@(mat) geomf(mat, 'K', 100, 'max_iter', 10, 'reg_1', 10, 'Y', item_grid), +(data>0), 'folds', 5);

%save('/home/dlian/data/checkin/Beijing/result.mat', 'metric_cv', 'metric_spatial_cv', 'metric_geo_cv', 'metric_cv100', 'metric_spatial_cv100', 'metric_geo_cv100');


%user_time = readContent('/home/dlian/data/checkin/Beijing/user_time.txt', 'nrows', M);
%user_time = NormalizeFea(user_time);
%item_time = readContent('/home/dlian/data/checkin/Beijing/item_time.txt', 'nrows', N);
%item_time = NormalizeFea(item_time);
%alg = @(varargin) item_recommend(@(mat) iccf(mat, 'reg_i', 50000, 'Y', [item_grid, item_time], 'X', user_time, 'K', 50, 'max_iter', 20, varargin{:}), train, 'test', test, 'topk', 100);
%metric_func = @(metric) metric.recall(1,end);
%[para, metric] = hyperp_search(alg, metric_func, 'reg_u', [1, 10, 100, 1000, 10000]);
%metric0 = item_recommend(@(mat) iccf(mat, 'X', user_time, 'Y', [item_grid, item_time], 'K', 50, 'max_iter', 20, 'reg_i', 50000,'reg_u', 1), train, 'test', test);
%metric1 = item_recommend(@(mat) iccf(mat, 'X', user_time, 'Y', [item_grid, item_time], 'K', 50, 'max_iter', 20, 'reg_i', 50000,'reg_u', 100), train, 'test', test);
%metric2 = item_recommend(@(mat) iccf(mat, 'X', user_time, 'Y', item_grid, 'K', 50, 'max_iter', 20, 'reg_i', 50000,'reg_u', 1), train, 'test', test);
%metric3 = item_recommend(@(mat) iccf(mat, 'X', user_time, 'Y', item_grid, 'K', 50, 'max_iter', 20, 'reg_i', 50000,'reg_u', 100), train, 'test', test);
%metric4 = item_recommend(@(mat) iccf(mat, 'Y', item_grid, 'K', 50, 'max_iter', 20, 'reg_i', 50000), train, 'test', test);
%metric5 = item_recommend(@(mat) iccf(mat, 'Y', [item_grid, item_time], 'K', 50, 'max_iter', 20, 'reg_i', 50000), train, 'test', test);


%metric = item_recommend(@geomf, train, 'test', test, 'topk',100, 'Y', item_grid);
%metric10_1 = item_recommend(@geomf, train, 'test', test, 'topk', 100, 'Y', item_grid, 'K', 50, 'reg_1', 10);

%% training shanghai data

data = readContent('/home/dlian/data/checkin/Shanghai/data.txt');
[~, N] = size(data);
item_grid = readContent('/home/dlian/data/checkin/Shanghai/item_grids_17.txt', 'nrows', N);
sigma = -1/log(1e-3);
item_grid(item_grid>0) = exp(-item_grid(item_grid>0).^2./sigma);
%item_grid = NormalizeFea(item_grid);

% trim some users and items
[data_trim, rows, cols] = trim_data(data, 20);
Y_trim = item_grid(cols,:);

[train, test] = split_matrix(+(data_trim>0), 'un', 0.8);


alg = @(varargin) item_recommend(@(mat) iccf(mat, 'K', 30, 'max_iter', 10, varargin{:}), train, 'test', test, 'topk', 100);
metric_func = @(metric) metric.recall(1,end);
[alpha, metric] = hyperp_search(alg, metric_func, 'alpha', [30, 50, 100, 200, 500]);


alg = @(varargin) item_recommend(@(mat) iccf(mat, 'alpha', 50, 'Y', Y_trim, 'K', 30, 'max_iter', 10, varargin{:}), train, 'test', test, 'topk', 100);
metric_func = @(metric) metric.recall(1,end);
%[regi, metric2] = hyperp_search(alg, metric_func, 'reg_i', [100, 1000, 5000, 10000, 50000, 100000]);
[regi, metric3] = hyperp_search(alg, metric_func, 'reg_i', [100000, 500000, 1000000, 5000000]);


metric_cv = item_recommend(@(mat) iccf(mat, 'alpha', 50, 'K', 50, 'max_iter', 20), +(data_trim>0), 'folds', 5);
metric_spatial_cv = item_recommend(@(mat) iccf(mat, 'alpha', 50, 'K', 50, 'max_iter', 20, 'Y', Y_trim, 'reg_i', 50000), +(data_trim>0), 'folds', 5);

metric_cv100 = item_recommend(@(mat) iccf(mat, 'alpha', 50, 'K', 100, 'max_iter', 20), +(data_trim>0), 'folds', 5);
metric_spatial_cv100 = item_recommend(@(mat) iccf(mat, 'alpha', 50, 'K', 100, 'max_iter', 20, 'Y', Y_trim, 'reg_i', 50000), +(data_trim>0), 'folds', 5);


save('/home/dlian/data/checkin/Shanghai/iccf.result.mat', 'metric_cv', 'metric_spatial_cv', 'metric_cv100', 'metric_spatial_cv100');

metric_cv150 = item_recommend(@(mat) iccf(mat, 'alpha', 50, 'K', 150, 'max_iter', 20), +(data_trim>0), 'folds', 5);
metric_spatial_cv150 = item_recommend(@(mat) iccf(mat, 'alpha', 50, 'K', 150, 'max_iter', 20, 'Y', Y_trim, 'reg_i', 50000), +(data_trim>0), 'folds', 5);
metric_cv200 = item_recommend(@(mat) iccf(mat, 'alpha', 50, 'K', 200, 'max_iter', 20), +(data_trim>0), 'folds', 5);
metric_spatial_cv200 = item_recommend(@(mat) iccf(mat, 'alpha', 50, 'K', 200, 'max_iter', 20, 'Y', Y_trim, 'reg_i', 50000), +(data_trim>0), 'folds', 5);
save('/home/dlian/data/checkin/Shanghai/result.mat', 'metric_cv', 'metric_spatial_cv', ...
    'metric_cv100', 'metric_spatial_cv100', 'metric_cv150', 'metric_spatial_cv150', 'metric_cv200', 'metric_spatial_cv200');

%% training Gowallal data

data = readContent('/home/dlian/data/checkin/Gowalla/data.txt');
[M, N] = size(data);
item_grid = readContent('/home/dlian/data/checkin/Gowalla/item_grids_17.txt', 'nrows', N);
sigma = -1/log(1e-3);
item_grid(item_grid>0) = exp(-item_grid(item_grid>0).^2./sigma);

[train, test] = split_matrix(+(data>0), 'un', 0.8);


alg = @(varargin) item_recommend(@(mat) iccf(mat, 'K', 30, 'max_iter', 10, varargin{:}), train, 'test', test, 'topk', 100);
metric_func = @(metric) metric.recall(1,end);
[alpha, metric] = hyperp_search(alg, metric_func, 'alpha', 1000:500:2000);


alg = @(varargin) item_recommend(@(mat) iccf(mat, 'alpha', 1000, 'Y', item_grid, 'K', 30, 'max_iter', 10, varargin{:}), train, 'test', test, 'topk', 100);
metric_func = @(metric) metric.recall(1,end);
[regi, metric2] = hyperp_search(alg, metric_func, 'reg_i', [1000, 5000, 10000, 50000, 100000]);
[regi, metric2] = hyperp_search(alg, metric_func, 'reg_i', [500000, 1000000,1500000,2000000]);


metric_cv = item_recommend(@(mat) iccf(mat, 'alpha', 1000, 'K', 50, 'max_iter', 20), +(data>0), 'folds', 5);
metric_spatial_cv = item_recommend(@(mat) iccf(mat, 'alpha', 1000, 'Y', item_grid, 'K', 50, 'max_iter', 20, 'reg_i', 1000000), +(data>0), 'folds', 5);
save('/home/dlian/data/checkin/Gowalla/iccf.result.mat', 'metric_cv', 'metric_spatial_cv');

metric_geo_cv = item_recommend(@(mat) geomf(mat, 'alpha', 1000, 'K', 50, 'max_iter', 10, 'reg_1', 10, 'Y', item_grid), +(data>0), 'folds', 5);
%metric_geo_cv100 = item_recommend(@(mat) geomf(mat, 'K', 100, 'max_iter', 10, 'reg_1', 10, 'Y', item_grid), +(data>0), 'folds', 5);

%save('/home/dlian/data/checkin/Beijing/result.mat', 'metric_cv', 'metric_spatial_cv', 'metric_geo_cv', 'metric_cv100', 'metric_spatial_cv100', 'metric_geo_cv100');


alpha = 1000; K = 50; reg_i = 1000000; reg_1 = 10;

%sensitive_analysis('/home/dlian/data/checkin/Gowalla', 1000, 50, 1000000, 10)

[~, ~, metric_train_wals, times_train_wals] = hyperp_search(...
    @(varargin) item_recommend(@iccf, +(data>0), 'test_ratio', 0.2, 'alpha', alpha, 'K', K, varargin{:}), ...
    @(metric) metric.recall(1,end), 'train_ratio', (0.2:0.2:1)*0.8);
[K_wals, ~, metric_K_wals, times_K_wals] = hyperp_search(...
    @(varargin) item_recommend(@iccf, +(data>0), 'test_ratio', 0.2, 'alpha', alpha, varargin{:}), ...
    @(metric) metric.recall(1,end), 'K', 50:50:300);
save('/home/dlian/data/checkin/Gowalla/sensitive.mat', 'metric_K_wals', 'times_K_wals','K_wals','metric_train_wals','times_train_wals', '-append');


[~, ~, metric_train_iccf, times_train_iccf] = hyperp_search(...
    @(varargin) item_recommend(@iccf, +(data>0), 'test_ratio', 0.2, 'alpha', alpha, 'K', K, 'Y', item_grid, 'reg_i', reg_i, varargin{:}), ...
    @(metric) metric.recall(1,end), 'train_ratio', (0.2:0.2:1)*0.8);
[K_iccf, ~, metric_K_iccf, times_K_iccf] = hyperp_search(...
    @(varargin) item_recommend(@iccf, +(data>0), 'test_ratio', 0.2, 'alpha', alpha, 'Y', item_grid, 'reg_i', reg_i, varargin{:}), ...
    @(metric) metric.recall(1,end), 'K', 50:50:300);
save('/home/dlian/data/checkin/Gowalla/sensitive.mat', 'metric_K_iccf', 'times_K_iccf','K_iccf','metric_train_iccf','times_train_iccf', '-append');

[~, ~, metric_train_piccf, times_train_piccf] = hyperp_search(...
    @(varargin) item_recommend(@piccf, +(data>0), 'test_ratio', 0.2, 'alpha', alpha, 'K', K, 'Y', item_grid, 'reg_i', reg_i, varargin{:}), ...
    @(metric) metric.recall(1,end), 'train_ratio', (0.2:0.2:1)*0.8);
[K_piccf, ~, metric_K_piccf, times_K_piccf] = hyperp_search(...
    @(varargin) item_recommend(@piccf, +(data>0), 'test_ratio', 0.2, 'alpha', alpha, 'Y', item_grid, 'reg_i', reg_i, varargin{:}), ...
    @(metric) metric.recall(1,end), 'K', 50:50:300);
save('/home/dlian/data/checkin/Gowalla/sensitive.mat', 'metric_K_piccf', 'times_K_piccf','K_piccf','metric_train_piccf','times_train_piccf', '-append');

[~, ~, metric_train_geomf, times_train_geomf] = hyperp_search(...
    @(varargin) item_recommend(@geomf, +(data>0), 'test_ratio', 0.2, 'alpha', alpha, 'K', K, 'Y', item_grid, 'reg_1', reg_1, varargin{:}), ...
    @(metric) metric.recall(1,end), 'train_ratio', (0.2:0.2:1)*0.8);
[K_geomf, ~, metric_K_geomf, times_K_geomf] = hyperp_search(...
    @(varargin) item_recommend(@geomf, +(data>0), 'test_ratio', 0.2, 'alpha', alpha, 'Y', item_grid, 'reg_1', reg_1, varargin{:}), ...
    @(metric) metric.recall(1,end), 'K', 50:50:300);

save('/home/dlian/data/checkin/Gowalla/sensitive.mat', 'metric_K_geomf', 'times_K_geomf','K_geomf','metric_train_geomf','times_train_geomf', '-append');


%% 
P = randn(N, 50);
X = item_grid;
U = zeros(size(X,2),50);
U1 = CD(P, U, X, 1, 1e-5);

F = size(X,2);
t = X.' * P;
%mat = X.' * X + reg * speye(F, F);
mat = X.' * X + spdiags(ones(F,1),0, F, F);
U = mat \ t;