import 'dart:async';
import 'package:flibusta/blocs/grid/grid_data/bloc.dart';
import 'package:flibusta/blocs/grid/grid_data/grid_data_repository.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/model/enums/gridViewType.dart';
import 'package:flibusta/model/extension_methods/dio_error_extension.dart';
import 'package:flibusta/model/grid_data/grid_data.dart';
import 'package:meta/meta.dart';

@immutable
abstract class GridDataEvent {
  Future<GridDataState> applyAsync(
      {GridDataState currentState, GridDataBloc bloc});

  final GridDataRepository _gridDataRepository = new GridDataRepository();
}

class LoadGridDataEvent extends GridDataEvent {
  @override
  String toString() => 'LoadGridDataEvent';

  @override
  Future<GridDataState> applyAsync(
      {GridDataState currentState, GridDataBloc bloc}) async {
    try {
      List<GridData> _gridData = [];
      var hasReachedMax = true;
      // TODO: add existing search string
      switch (bloc.gridViewType) {
        case GridViewType.downloaded:
          _gridData = await _gridDataRepository.getDownloadedBooks(1);
          hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          break;
        case GridViewType.newBooks:
          _gridData = await _gridDataRepository.makeBookList(1);
          hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          break;
        case GridViewType.authors:
          _gridData = await _gridDataRepository.getAuthors(1);
          hasReachedMax = (_gridData?.length ?? 0) < 49;
          break;
        case GridViewType.genres:
          _gridData = await _gridDataRepository.getAllGenres(1);
          hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          break;
        case GridViewType.sequences:
          break;
        default:
      }

      return currentState.copyWith(
        stateCode: GridDataStateCode.Normal,
        page: 1,
        hasReachedMax: hasReachedMax,
        gridData: _gridData,
        uploadingMore: false,
        message: '',
      );
    } on DsError catch (dsError) {
      return currentState.copyWith(
        stateCode: GridDataStateCode.Error,
        uploadingMore: false,
        message: dsError.toString(),
      );
    }
  }
}

class SearchGridDataEvent extends GridDataEvent {
  final String searchString;

  SearchGridDataEvent(this.searchString);
  @override
  String toString() => 'SearchGridDataEvent';

  @override
  Future<GridDataState> applyAsync(
      {GridDataState currentState, GridDataBloc bloc}) async {
    try {
      List<GridData> _gridData = [];
      var hasReachedMax = true;
      // TODO: add existing search string
      switch (bloc.gridViewType) {
        case GridViewType.downloaded:
          _gridData = await _gridDataRepository.getDownloadedBooks(1);
          hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          break;
        case GridViewType.newBooks:
          _gridData = await _gridDataRepository.makeBookList(1);
          hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          break;
        case GridViewType.authors:
          _gridData = await _gridDataRepository.getAuthors(1);
          hasReachedMax = (_gridData?.length ?? 0) < 49;
          break;
        case GridViewType.genres:
          _gridData = await _gridDataRepository.getAllGenres(1);
          hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          break;
        case GridViewType.sequences:
          break;
        default:
      }

      return currentState.copyWith(
        stateCode: GridDataStateCode.Normal,
        searchString: searchString,
        page: 1,
        hasReachedMax: hasReachedMax,
        gridData: _gridData,
        uploadingMore: false,
        message: '',
      );
    } catch (e) {
      return currentState.copyWith(
        stateCode: GridDataStateCode.Error,
        searchString: searchString,
        uploadingMore: false,
        message: e.toString(),
      );
    }
  }
}

class UploadMoreGridDataEvent extends GridDataEvent {
  final int pageNumber;

  UploadMoreGridDataEvent(this.pageNumber);

  @override
  String toString() => 'UploadMoreGridDataEvent';

  @override
  Future<GridDataState> applyAsync(
      {GridDataState currentState, GridDataBloc bloc}) async {
    try {
      List<GridData> _gridData = [];
      var hasReachedMax = true;
      // TODO: add existing search string
      switch (bloc.gridViewType) {
        case GridViewType.downloaded:
          _gridData = await _gridDataRepository.getDownloadedBooks(pageNumber);
          break;
        case GridViewType.newBooks:
          _gridData = await _gridDataRepository.makeBookList(
            pageNumber,
            lastGenres: (currentState.gridData.last as BookCard).genres?.list,
          );
          break;
        case GridViewType.authors:
          _gridData = await _gridDataRepository.getAuthors(pageNumber);
          break;
        case GridViewType.genres:
          _gridData = await _gridDataRepository.getAllGenres(pageNumber);
          break;
        case GridViewType.sequences:
          break;
        default:
      }
      hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
      if (currentState.uploadingMore == true) {
        _gridData = [...currentState.gridData, ..._gridData];
      }

      return currentState.copyWith(
        stateCode: GridDataStateCode.Normal,
        page: pageNumber,
        hasReachedMax: hasReachedMax,
        gridData: _gridData,
        uploadingMore: false,
        message: '',
      );
    } catch (e) {
      return currentState.copyWith(
        stateCode: GridDataStateCode.Error,
        uploadingMore: false,
        message: e.toString(),
      );
    }
  }
}
