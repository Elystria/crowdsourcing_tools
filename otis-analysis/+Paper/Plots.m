classdef (Abstract) Plots


methods (Static, Access=private)


function fig_handle = box ( all_quantiles, labels, x_label, x_axis, fig_size )
% Make a box plot with consistent configuration parameters.
	% Transform quantiles [0, 0.25, 0.5, 0.75, 1] to a vector usable by "boxplot".
	% The trick to be able to use boxplot is to add the median once.
	plotable_quantiles = cellfun ...
		( @(quantiles) [ quantiles(:); quantiles(3) ] ...
		, all_quantiles ...
		, 'UniformOutput', false ...
		);
	fig_handle = figure;
	set( fig_handle, 'Visible', 'off' );
	boxplot ...
		( cell2mat( plotable_quantiles ) ...
		, labels ...
		, 'Orientation', 'horizontal' ...
		, 'PlotStyle', 'compact' ...
		, 'Whisker', inf ...
		);
	nb_lines = length( labels );
	y_axis = [ 0, nb_lines + 1 ];
	axis( [ x_axis, y_axis ] );
	xlabel( x_label, 'FontSize', 12 );
	set( gcf, 'units', 'points', 'position', [0, 0, fig_size] );
	pbaspect( [20, nb_lines + 1, 1] );
end


function savePdf ( fig_handle, file_path )
% Save the given figure into a pdf file.
	pos = get( fig_handle, 'Position' );
	set( fig_handle ...
		, 'PaperPositionMode', 'Auto' ...
		, 'PaperUnits', 'points' ...
		, 'PaperSize', pos(3:4) ...
		);
	print( fig_handle, file_path, '-dpdf', '-r0' );
end


function results = evalMethod ( method, varargin )
% Group [ precision, recall, and jaccard ] of an evaluation method
% into one struct having the .precision, .recall and .jaccard fields.
	results = struct;
	[ results.precisions, results.recalls, results.jaccards, results.masks ] = method( varargin{:} );
end


function [ p, r, j, masks ] = evalAllUsers ( users, method, varargin )
% Evaluate one method over all given users.
% Regroup precision, recall and jaccard results into distinct variables.
	all_results = Utils.mycellfun ...
		( @(user) Paper.Plots.evalMethod( method, user, varargin{:} ), users );
	p = cell2mat( Utils.mycellfun( @(results) results.precisions, all_results ) );
	r = cell2mat( Utils.mycellfun( @(results) results.recalls, all_results ) );
	j = cell2mat( Utils.mycellfun( @(results) results.jaccards, all_results ) );
	masks = Utils.mycellfun( @(results) results.masks, all_results );
end


end % private methods


methods (Static)


function duration ( users, file_path )
% Plot Figure 10.
% users must be an horizontal cell array. { user1, ..., usern }.
	cache_dir = fullfile( fileparts( file_path ), 'cache' );
	durations_rectangle = Utils.cached( fullfile( cache_dir, 'dur_rect.mat' ) ...
		, @Utils.mycellfun ...
		, @(user) User.Log.Time.allSelections( user.log.study.rectangle ) ...
		, users ...
		);
	durations_outline = Utils.cached( fullfile( cache_dir, 'dur_out.mat' ) ...
		, @Utils.mycellfun ...
		, @(user) User.Log.Time.allSelections( user.log.study.outline ) ...
		, users ...
		);
	durations_scribbles = Utils.cached( fullfile( cache_dir, 'dur_scrib.mat' ) ...
		, @Utils.mycellfun ...
		, @(user) User.Log.Time.allScribbles( user.log.study.scribbles ) ...
		, users ...
		);
	quantiles = Utils.mycellfun ...
		( @(durations) quantile( cell2mat( durations ), linspace( 0, 1, 5 ) ) ...
		, { durations_rectangle, durations_outline, durations_scribbles } ...
		);
	labels = { 'Bounding box', 'Outline', 'Scribbles' };
	x_label = 'Duration of interaction type in seconds (lower is better)';
	x_axis = [ 0, 20 ];
	fig_size = [ 600, 200 ];
	fig_handle = Paper.Plots.box( quantiles, labels, x_label, x_axis, fig_size );
	Paper.Plots.savePdf( fig_handle, file_path );
	close all;
end


function errors ( users, file_path )
% Plot Figure 11.
	cache_dir = fullfile( fileparts( file_path ), 'cache' );
	errors_rectangle = Utils.cached( fullfile( cache_dir, 'err_rect.mat' ) ...
		, @cellfun ...
		, @(user) sum( User.Data.Errors.allSelections( user.data.rectangle ) ) ...
		, users ...
		);
	errors_outline = Utils.cached( fullfile( cache_dir, 'err_out.mat' ) ...
		, @cellfun ...
		, @(user) sum( User.Data.Errors.allSelections( user.data.outline ) ) ...
		, users ...
		);
	errors_scribbles = Utils.cached( fullfile( cache_dir, 'err_scrib.mat' ) ...
		, @cellfun ...
		, @(user) sum( User.Data.Errors.allScribbles( user.data.scribbles ) ) ...
		, users ...
		);
	quantiles = Utils.mycellfun ...
		( @(errors) quantile( errors, linspace( 0, 1, 5 ) ) ...
		, { errors_rectangle, errors_outline, errors_scribbles } ...
		);
	labels = { 'Bounding box', 'Outline', 'Scribbles' };
	x_label = 'Number of wrong attempts for all 11 images (lower is better)';
	x_axis = [ 0, 15 ];
	fig_size = [ 600, 200 ];
	fig_handle = Paper.Plots.box( quantiles, labels, x_label, x_axis, fig_size );
	Paper.Plots.savePdf( fig_handle, file_path );
	close all;
end


function background ( users, all_gts, all_sp, file_path_precision, file_path_recall )
% Plot Figure 12 and 13 (background user input).
	cache_dir = fullfile( fileparts( file_path_precision ), 'cache' );
	[ precisions_rect, recalls_rect, ~ ] = ...
		Utils.cached( fullfile( cache_dir, 'bg_rect.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Rectangle.bg, all_gts.rectangle );
	[ precisions_outlines, recalls_outlines, ~ ] = ...
		Utils.cached( fullfile( cache_dir, 'bg_out.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Outline.bg, all_gts.outline );
	[ precisions_scribbles, recalls_scribbles, ~ ] = ...
		Utils.cached( fullfile( cache_dir, 'bg_scrib.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Scribbles.bgSP, all_gts.scribbles, all_sp.scribbles );

	% Figure 12 (precision).
	quantiles = Utils.mycellfun ...
		( @(values) quantile( values, linspace( 0, 1, 5 ) ) ...
		, { precisions_scribbles, precisions_rect, precisions_outlines } ...
		);
	labels = { 'Scribbles with superpixels', 'Bounding box', 'Outline' };
	x_label = 'Precision of background user input';
	x_axis = [ 0.6, 1 ];
	fig_size = [ 600, 200 ];
	fig_handle = Paper.Plots.box( quantiles, labels, x_label, x_axis, fig_size );
	Paper.Plots.savePdf( fig_handle, file_path_precision );
	close all;

	% Figure 13 (recall).
	quantiles = Utils.mycellfun ...
		( @(values) quantile( values, linspace( 0, 1, 5 ) ) ...
		, { recalls_scribbles, recalls_rect, recalls_outlines } ...
		);
	labels = { 'Scribbles with superpixels', 'Bounding box', 'Outline' };
	x_label = 'Recall of background user input';
	x_axis = [ 0, 1 ];
	fig_size = [ 600, 200 ];
	fig_handle = Paper.Plots.box( quantiles, labels, x_label, x_axis, fig_size );
	Paper.Plots.savePdf( fig_handle, file_path_recall );
	close all;
end


function foreground ( users, all_gts, all_sp, file_path_precision, file_path_recall )
% Plot Figure 14 and 15 (inferred foreground user input).
	cache_dir = fullfile( fileparts( file_path_precision ), 'cache' );
	[ p_scrib, r_scrib, ~ ] = ...
		Utils.cached( fullfile( cache_dir, 'fg_scrib.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Scribbles.fg, all_gts.scribbles );
	[ p_scrib_sp, r_scrib_sp, ~ ] = ...
		Utils.cached( fullfile( cache_dir, 'fg_scrib_sp.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Scribbles.fgSP, all_gts.scribbles, all_sp.scribbles );
	[ p_skel, r_skel, ~ ] = ...
		Utils.cached( fullfile( cache_dir, 'fg_skel.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Outline.skeleton, all_gts.outline );
	[ p_skel_sp, r_skel_sp, ~ ] = ...
		Utils.cached( fullfile( cache_dir, 'fg_skel_sp.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Outline.skeletonSP, all_gts.outline, all_sp.outline );
	[ p_erosion, r_erosion, ~ ] = ...
		Utils.cached( fullfile( cache_dir, 'fg_erosion.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Outline.erosion, all_gts.outline );
	[ p_erosion_sp, r_erosion_sp, ~ ] = ...
		Utils.cached( fullfile( cache_dir, 'fg_erosion_sp.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Outline.erosionSP, all_gts.outline, all_sp.outline );

	% Figure 14 (precision).
	quantiles = Utils.mycellfun ...
		( @(values) quantile( values, linspace( 0, 1, 5 ) ) ...
		, { p_scrib, p_scrib_sp, p_skel, p_skel_sp, p_erosion, p_erosion_sp } ...
		);
	labels = ...
		{ 'Scribbles', 'Scribbles with superpixels' ...
		, 'Skeleton of outline', 'Skeleton of outline with superpixels' ...
		, 'Erosion of outline', 'Erosion of outline with superpixels' ...
		};
	x_label = 'Precision of inferred foreground';
	x_axis = [ 0.84, 1 ];
	fig_size = [ 600, 400 ];
	fig_handle = Paper.Plots.box( quantiles, labels, x_label, x_axis, fig_size );
	Paper.Plots.savePdf( fig_handle, file_path_precision );
	close all;

	% Figure 15 (recall).
	quantiles = Utils.mycellfun ...
		( @(values) quantile( values, linspace( 0, 1, 5 ) ) ...
		, { r_scrib, r_scrib_sp, r_skel, r_skel_sp, r_erosion, r_erosion_sp } ...
		);
	labels = ...
		{ 'Scribbles', 'Scribbles with superpixels' ...
		, 'Skeleton of outline', 'Skeleton of outline with superpixels' ...
		, 'Erosion of outline', 'Erosion of outline with superpixels' ...
		};
	x_label = 'Recall of inferred foreground';
	x_axis = [ 0, 1 ];
	fig_size = [ 600, 400 ];
	fig_handle = Paper.Plots.box( quantiles, labels, x_label, x_axis, fig_size );
	Paper.Plots.savePdf( fig_handle, file_path_recall );
	close all;
end


function durationPoster ( users, file_path )
% Plot duration (poster-specific).
% users must be an horizontal cell array. { user1, ..., usern }.
	cache_dir = fullfile( fileparts( file_path ), 'cache' );
	durations_rectangle = Utils.cached( fullfile( cache_dir, 'dur_rect.mat' ) ...
		, @Utils.mycellfun ...
		, @(user) User.Log.Time.allSelections( user.log.study.rectangle ) ...
		, users ...
		);
	durations_outline = Utils.cached( fullfile( cache_dir, 'dur_out.mat' ) ...
		, @Utils.mycellfun ...
		, @(user) User.Log.Time.allSelections( user.log.study.outline ) ...
		, users ...
		);
	durations_scribbles = Utils.cached( fullfile( cache_dir, 'dur_scrib.mat' ) ...
		, @Utils.mycellfun ...
		, @(user) User.Log.Time.allScribbles( user.log.study.scribbles ) ...
		, users ...
		);
	quantiles = Utils.mycellfun ...
		( @(durations) quantile( cell2mat( durations ), linspace( 0, 1, 5 ) ) ...
		, { durations_rectangle, durations_outline, durations_scribbles } ...
		);
	labels = { 'Bounding box', 'Outline', 'Scribbles' };
	x_label = 'Duration of interaction type in seconds (lower is better)';
	x_axis = [ 0, 14 ];
	fig_size = [ 350, 200 ];
	fig_handle = Paper.Plots.box( quantiles, labels, x_label, x_axis, fig_size );
	Paper.Plots.savePdf( fig_handle, file_path );
	close all;
end


function errorsPoster ( users, file_path )
% Plot errors (poster-specific).
	cache_dir = fullfile( fileparts( file_path ), 'cache' );
	errors_rectangle = Utils.cached( fullfile( cache_dir, 'err_rect.mat' ) ...
		, @cellfun ...
		, @(user) sum( User.Data.Errors.allSelections( user.data.rectangle ) ) ...
		, users ...
		);
	errors_outline = Utils.cached( fullfile( cache_dir, 'err_out.mat' ) ...
		, @cellfun ...
		, @(user) sum( User.Data.Errors.allSelections( user.data.outline ) ) ...
		, users ...
		);
	errors_scribbles = Utils.cached( fullfile( cache_dir, 'err_scrib.mat' ) ...
		, @cellfun ...
		, @(user) sum( User.Data.Errors.allScribbles( user.data.scribbles ) ) ...
		, users ...
		);
	quantiles = Utils.mycellfun ...
		( @(errors) quantile( errors, linspace( 0, 1, 5 ) ) ...
		, { errors_rectangle, errors_outline, errors_scribbles } ...
		);
	labels = { 'Bounding box', 'Outline', 'Scribbles' };
	x_label = 'Number of wrong attempts for all 11 images (lower is better)';
	x_axis = [ 0, 12 ];
	fig_size = [ 350, 200 ];
	fig_handle = Paper.Plots.box( quantiles, labels, x_label, x_axis, fig_size );
	Paper.Plots.savePdf( fig_handle, file_path );
	close all;
end


function bgPoster ( users, all_gts, all_sp, file_path_recall )
% Plot recall of background (poster-specific).
	cache_dir = fullfile( fileparts( file_path_recall ), 'cache' );
	[ ~, recalls_rect, ~ ] = ...
		Utils.cached( fullfile( cache_dir, 'bg_rect.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Rectangle.bg, all_gts.rectangle );
	[ ~, recalls_outlines, ~ ] = ...
		Utils.cached( fullfile( cache_dir, 'bg_out.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Outline.bg, all_gts.outline );
	[ ~, recalls_scribbles, ~ ] = ...
		Utils.cached( fullfile( cache_dir, 'bg_scrib.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Scribbles.bgSP, all_gts.scribbles, all_sp.scribbles );

	% Recall bg (poster-specific).
	quantiles = Utils.mycellfun ...
		( @(values) quantile( values, linspace( 0, 1, 5 ) ) ...
		, { recalls_scribbles, recalls_rect, recalls_outlines } ...
		);
	labels = { 'Scribbles with superpixels', 'Bounding box', 'Outline' };
	x_label = 'Recall of background user input';
	x_axis = [ 0.5, 1 ];
	fig_size = [ 350, 200 ];
	fig_handle = Paper.Plots.box( quantiles, labels, x_label, x_axis, fig_size );
	Paper.Plots.savePdf( fig_handle, file_path_recall );
	close all;
end


function fgPoster ( users, all_gts, all_sp, file_path_precision )
% Plot precision of foreground (poster-specific).
	cache_dir = fullfile( fileparts( file_path_precision ), 'cache' );
	[ p_scrib, ~, ~ ] = ...
		Utils.cached( fullfile( cache_dir, 'fg_scrib.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Scribbles.fg, all_gts.scribbles );
	[ p_scrib_sp, ~, ~ ] = ...
		Utils.cached( fullfile( cache_dir, 'fg_scrib_sp.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Scribbles.fgSP, all_gts.scribbles, all_sp.scribbles );
	[ p_skel, ~, ~ ] = ...
		Utils.cached( fullfile( cache_dir, 'fg_skel.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Outline.skeleton, all_gts.outline );
	[ p_skel_sp, ~, ~ ] = ...
		Utils.cached( fullfile( cache_dir, 'fg_skel_sp.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Outline.skeletonSP, all_gts.outline, all_sp.outline );
	[ p_erosion, ~, ~ ] = ...
		Utils.cached( fullfile( cache_dir, 'fg_erosion.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Outline.erosion, all_gts.outline );
	[ p_erosion_sp, ~, ~ ] = ...
		Utils.cached( fullfile( cache_dir, 'fg_erosion_sp.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Outline.erosionSP, all_gts.outline, all_sp.outline );

	% Precision fg (poster-specific).
	quantiles = Utils.mycellfun ...
		( @(values) quantile( values, linspace( 0, 1, 5 ) ) ...
		, { p_scrib, p_scrib_sp, p_skel, p_skel_sp, p_erosion, p_erosion_sp } ...
		);
	labels = ...
		{ 'Scribbles', 'Scribbles with superpixels' ...
		, 'Skeleton of outline', 'Skeleton of outline with superpixels' ...
		, 'Erosion of outline', 'Erosion of outline with superpixels' ...
		};
	x_label = 'Precision of inferred foreground';
	x_axis = [ 0.84, 1 ];
	fig_size = [ 450, 400 ];
	fig_handle = Paper.Plots.box( quantiles, labels, x_label, x_axis, fig_size );
	Paper.Plots.savePdf( fig_handle, file_path_precision );
	close all;
end


function saveAllUsersMasks( all_masks, save_dir, base_name )
% Save masks on disk, grouped in one folder per user.
	saveUserIdMasks = @(user_id) ...
		( Paper.Plots.saveUserMasks ...
			( all_masks{user_id} ...
			, fullfile( save_dir, ['user_' int2str(user_id)] ) ...
			, base_name ) );
	arrayfun( saveUserIdMasks, 1:length(all_masks), 'UniformOutput', false );
end

function saveUserMasks( masks, user_dir, base_name )
	saveMask = @(id) imwrite( masks{id}, fullfile( user_dir, [ base_name '_' int2str(id) '.png' ] ) );
	Utils.mkParentDir( fullfile( user_dir, 'whatever' ) );
	arrayfun( saveMask, 1:length(masks), 'UniformOutput', false );
end


function segmentation ( users, images, all_gts, all_sp, file_path )
% Plot Figure 16.
	cache_dir = fullfile( fileparts( file_path ), 'cache' );

	disp( 'Computing GrabCut for outlines (no foreground)...' );
	[ ~, ~, jaccards_out_none, masks_out_none ] = ...
		Utils.cached( fullfile( cache_dir, 'seg_out_none.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Outline.grabcut, images.outline, all_gts.outline, all_sp.outline, 'none', 'none' );
	Paper.Plots.saveAllUsersMasks( masks_out_none, fullfile( cache_dir, 'masks_png' ), 'out_none' );

	disp( 'Computing GrabCut for outlines (erosion)...' );
	[ ~, ~, jaccards_out_erosion, masks_out_erosion ] = ...
		Utils.cached( fullfile( cache_dir, 'seg_out_erosion.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Outline.grabcut, images.outline, all_gts.outline, all_sp.outline, 'erosion', 'soft' );
	Paper.Plots.saveAllUsersMasks( masks_out_erosion, fullfile( cache_dir, 'masks_png' ), 'out_erosion' );

	disp( 'Computing GrabCut for outlines (skeleton)...' );
	[ ~, ~, jaccards_out_skel, masks_out_skel ] = ...
		Utils.cached( fullfile( cache_dir, 'seg_out_skel.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Outline.grabcut, images.outline, all_gts.outline, all_sp.outline, 'skeleton', 'soft' );
	Paper.Plots.saveAllUsersMasks( masks_out_skel, fullfile( cache_dir, 'masks_png' ), 'out_skel' );

	disp( 'Computing GrabCut for scribbles ...' );
	[ ~, ~, jaccards_scrib, masks_scrib ] = ...
		Utils.cached( fullfile( cache_dir, 'seg_scr.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Scribbles.grabcut, images.scribbles, all_gts.scribbles, all_sp.scribbles, 'soft' );
	Paper.Plots.saveAllUsersMasks( masks_scrib, fullfile( cache_dir, 'masks_png' ), 'scribbles' );

	disp( 'Computing GrabCut for bounding boxes ...' );
	[ ~, ~, jaccards_rect, masks_rect ] = ...
		Utils.cached( fullfile( cache_dir, 'seg_rec.mat' ) ...
			, @Paper.Plots.evalAllUsers ...
			, users, @User.Eval.Rectangle.grabcut, images.rectangle, all_gts.rectangle, all_sp.rectangle );
	Paper.Plots.saveAllUsersMasks( masks_rect, fullfile( cache_dir, 'masks_png' ), 'bbox' );

	quantiles = Utils.mycellfun ...
		( @(values) quantile( values, linspace( 0, 1, 5 ) ) ...
		, { jaccards_rect, jaccards_scrib, jaccards_out_none, jaccards_out_erosion, jaccards_out_skel } ...
		);
	labels = ...
		{ 'Bounding box', 'Scribbles', 'Outline' ...
		, 'Erosion of outline with superpixels' ...
		, 'Skeleton of outline with superpixels' ...
		};
	x_label = 'Jaccard index of final segmentations';
	x_axis = [ 0.5, 1 ];
	fig_size = [ 600, 400 ];
	fig_handle = Paper.Plots.box( quantiles, labels, x_label, x_axis, fig_size );
	Paper.Plots.savePdf( fig_handle, file_path );
	close all;
	save;
end

end % methods


end