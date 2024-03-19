//mb_detail_view

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:works_shg_app/models/employee/mb/mb_inbox_response.dart';

import '../../../data/remote_client.dart';
import '../../../data/repositories/employee_repository/mb.dart';
import '../../../models/employee/mb/filtered_Measures.dart';
import '../../../models/employee/mb/mb_detail_response.dart';
import '../../../services/urls.dart';
import '../../../utils/employee/mb/mb_logic.dart';

part 'mb_detail_view.freezed.dart';

typedef MeasurementDetailBlocEventEmitter = Emitter<MeasurementDetailState>;

class MeasurementDetailBloc
    extends Bloc<MeasurementDetailBlocEvent, MeasurementDetailState> {
  MeasurementDetailBloc() : super(const MeasurementDetailState.initial()) {
    on<MeasurementDetailBookBlocEvent>(getMBInbox);
    on<AddToMeasurementLineEvent>(addMeasurementLine);
    on<UpdateToMeasurementLineEvent>(updateMeasurementLine);
    on<UpdateViewModeEvent>(updateViewMode);
    on<CancelUpdateEvent>(cancelUpdate);
    on<SubmitLineEvent>(updatePriceSOR);
  }
  FutureOr<void> getMBInbox(
    MeasurementDetailBookBlocEvent event,
    MeasurementDetailBlocEventEmitter emit,
  ) async {
    Client client = Client();
    try {
      emit(const MeasurementDetailState.initial());
      emit(const MeasurementDetailState.loading());
      final MBDetailResponse res = await MBRepository(client.init())
          .fetchMbDetail(url: Urls.measurementService.measurementDetail, body: {
        // "contractNumber": "WO/2023-24/001379",
        // "tenantId": "od.testing",
        // "measurementNumber": "MB/2023-24/000214",
        // "key": "View",
        "contractNumber": event.contractNumber,
        "tenantId": "od.testing",
        "measurementNumber": event.measurementNumber,
        "key": "View",
      });

      // final kk = jsonEncode(res.allMeasurements!.first!.copyWith(
      //     workflow: const WorkFlow(
      //   action: "Submit",
      //   assignees: ["NESK"],
      //   comment: "loading",
      // )));
      // print(kk);
      final List<FilteredMeasurements> data =
          MBLogic.getMeasureList(mbDetailResponse: res);

      List<List<List<SorObject>>> sorList = MBLogic.getSors(data);

      emit(
        MeasurementDetailState.loaded(
          null,
          true,
          res.allMeasurements!.first,
          data,
          sorList.first.first,
          sorList.first.last,
          sorList.length > 2 ? sorList[1].first : null,
          sorList.length > 2 ? sorList[1].last : null,
        ),
      );
    } on DioError catch (e) {
      // emit(MeasurementInboxState.error(e.response?.data['Errors'][0]['code']));
      emit(MeasurementDetailState.error(e.toString()));
    }
  }

  FutureOr<void> addMeasurementLine(
    AddToMeasurementLineEvent event,
    MeasurementDetailBlocEventEmitter emit,
  ) async {
    try {
      state.maybeMap(
        orElse: () => null,
        loaded: (value) {
          print(event.sorId);
          print(event.type);
          List<MeasureLineItem> mk = [];
          // MeasureLineItem ml = MeasureLineItem(
          //   width: event.width,
          //   height: event.height,
          //   length: event.length,
          //   number: event.number,
          //   quantity: (calulateQuantity(
          //       height: event.height,
          //       width: event.width,
          //       length: event.length,
          //       number: event.number)),
          //   measurelineitemNo: event.measurementLineIndex,
          // );
          MeasureLineItem mm = const MeasureLineItem(
            width: 0,
            height: 0,
            length: 0,
            number: 0,
            quantity: 0,
            measurelineitemNo: 1,
          );
          if (event.single) {
            mk = [mm];
          } else {
            mk = [mm];
          }

          // final measurementLineIndex = 0;
          // final sorID = "SOR_000143";
          // final filteredMeasurementsMeasureId =
          //     "594d0557-9bc5-467b-9ff1-babf76e6a24e";
// List<SorObject> sorObjects, String sorId,
//       String filteredMeasurementsMeasureId, int measurementLineIndex, MeasureLineItem updatedMeasurementLine

          if (event.type != "NON-SOR") {
            List<SorObject> data = MBLogic.addMeasurementLine(
              value.sor!,
              event.sorId,
              event.filteredMeasurementMeasureId!,
              event.measurementLineIndex!,
              mk,
            );

            emit(value.copyWith(
              sor: data,
            ));
          } else {
            List<SorObject> data = MBLogic.addMeasurementLine(
              value.nonSor!,
              event.sorId,
              event.filteredMeasurementMeasureId!,
              event.measurementLineIndex!,
              mk,
            );

            emit(value.copyWith(
              nonSor: data,
            ));
          }
        },
      );
    } catch (e) {
      // emit(MeasurementInboxState.error(e.response?.data['Errors'][0]['code']));
      // emit(MeasurementDetailState.error(e.toString()));
    }
  }

  // update mbline

  FutureOr<void> updateMeasurementLine(
    UpdateToMeasurementLineEvent event,
    MeasurementDetailBlocEventEmitter emit,
  ) async {
    try {
      state.maybeMap(
        orElse: () => null,
        loaded: (value) {
          double target = MBLogic.calculateTotalQuantityAndSkip(
            value.sor!,
            event.sorId,
            event.filteredMeasurementMeasureId!,
            event.measurementLineIndex!,
          );
          print("bubu$target");
          print(event.sorId);
          print(event.type);

          double currentLineQty = double.parse(calulateQuantity(
                  height: event.height,
                  width: event.width,
                  length: event.length,
                  number: event.number)
              .toString());

          if ((currentLineQty + target) <=
              (double.parse(event.noOfUnit.toString()) -
                  double.parse(event.cummulativePrevQty.toString()))) {
            MeasureLineItem ml = MeasureLineItem(
              width: event.width,
              height: event.height,
              length: event.length,
              number: event.number,
              quantity: calulateQuantity(
                  height: event.height,
                  width: event.width,
                  length: event.length,
                  number: event.number),
              measurelineitemNo: event.measurementLineIndex,
            );

            if (event.type != "NON-SOR") {
              List<SorObject> data = MBLogic.updateMeasurementLine(
                value.sor!,
                event.sorId,
                event.filteredMeasurementMeasureId!,
                event.measurementLineIndex!,
                ml,
              );

              emit(value.copyWith(
                sor: data,
                warningMsg: null,
              ));
            } else {
              List<SorObject> data = MBLogic.updateMeasurementLine(
                value.nonSor!,
                event.sorId,
                event.filteredMeasurementMeasureId!,
                event.measurementLineIndex!,
                ml,
              );

              emit(value.copyWith(
                nonSor: data,
                warningMsg: null,
              ));
            }
          } else {
            emit(value.copyWith(
              warningMsg: "please check the number",
            ));
          }
        },
      );
    } catch (e) {
      // emit(MeasurementInboxState.error(e.response?.data['Errors'][0]['code']));
      emit(MeasurementDetailState.error(e.toString()));
    }
  }

// update view mode
  FutureOr<void> updateViewMode(
    UpdateViewModeEvent event,
    MeasurementDetailBlocEventEmitter emit,
  ) async {
    try {
      state.maybeMap(
        orElse: () => null,
        loaded: (value) {
          emit(
            value.copyWith(
              viewStatus: event.updateView,
            ),
          );
        },
      );
    } catch (e) {
      // emit(MeasurementInboxState.error(e.response?.data['Errors'][0]['code']));
      // emit(MeasurementDetailState.error(e.toString()));
    }
  }

// calcel view mode
  FutureOr<void> cancelUpdate(
    CancelUpdateEvent event,
    MeasurementDetailBlocEventEmitter emit,
  ) async {
    try {
      state.maybeMap(
        orElse: () => null,
        loaded: (value) {
          List<List<List<SorObject>>> sorList = MBLogic.getSors(value.data);

          emit(
            value.copyWith(
              warningMsg: null,
              sor: sorList.first.first,
              nonSor: sorList.first.last,
              preSor: sorList.length > 2 ? sorList[1].first : null,
              preNonSor: sorList.length > 2 ? sorList[1].last : null,
            ),
          );
        },
      );
    } catch (e) {
      // emit(MeasurementInboxState.error(e.response?.data['Errors'][0]['code']));
      // emit(MeasurementDetailState.error(e.toString()));
    }
  }

// calculate qty
  dynamic calulateQuantity({
    required dynamic height,
    required dynamic width,
    required dynamic length,
    required dynamic number,
  }) {
    //return  field==0?1:field;

    if ((height == '0' && width == '0' && length == '0' && number == '0') ||
        (height == '0.0' &&
            width == '0.0' &&
            length == '0.0' &&
            number == '0.0') ||
        (height == 0 && width == 0 && length == 0 && number == 0) ||
        (height == 0.0 && width == 0.0 && length == 0.0 && number == 0.0)) {
      return 0;
    } else {
      if (height == '0' || height == '0.0') {
        height = 1;
      }
      if (width == '0' || width == '0.0') {
        width = 1;
      }
      if (length == '0' || length == '0.0') {
        length = 1;
      }
      if (number == '0' || number == '0.0') {
        number = 1;
      }

      return (double.parse(height.toString()) *
              double.parse(width.toString()) *
              double.parse(length.toString()) *
              double.parse(number.toString()))
          .toString();
    }
  }

// update price
  FutureOr<void> updatePriceSOR(
    SubmitLineEvent event,
    MeasurementDetailBlocEventEmitter emit,
  ) async {
    try {
      state.maybeMap(
        orElse: () => null,
        loaded: (value) {
         
          List<SorObject> sorData = MBLogic.calculateTotalQuantity(
              value.sor!, "sorId", "filteredMeasurementsMeasureId", 0);

          List<SorObject> nonSorData = MBLogic.calculateTotalQuantity(
              value.nonSor!, "sorId", "filteredMeasurementsMeasureId", 0);

          emit(
            value.copyWith(
              warningMsg: null,
              sor: sorData,
              nonSor: nonSorData,
            ),
          );
        },
      );
    } on DioError catch (e) {
      // emit(MeasurementInboxState.error(e.response?.data['Errors'][0]['code']));
      emit(MeasurementDetailState.error(e.toString()));
    }
  }
}

@freezed
class MeasurementDetailBlocEvent with _$MeasurementDetailBlocEvent {
  const factory MeasurementDetailBlocEvent.create({
    required String tenantId,
    required String contractNumber,
    required String measurementNumber,
  }) = MeasurementDetailBookBlocEvent;

  const factory MeasurementDetailBlocEvent.clear() =
      MeasurementDetailBlocClearEvent;
  const factory MeasurementDetailBlocEvent.addToMeasurementLineList({
    required String sorId,
    required String type,
    int? index,
    int? measurementLineIndex,
    String? filteredMeasurementMeasureId,
    dynamic height,
    dynamic width,
    dynamic length,
    dynamic number,
    dynamic quantity,
    required bool single,
  }) = AddToMeasurementLineEvent;

  const factory MeasurementDetailBlocEvent.updateToMeasurementLineList({
    required dynamic noOfUnit,
    required dynamic cummulativePrevQty,
    required String sorId,
    required String type,
    int? index,
    int? measurementLineIndex,
    String? filteredMeasurementMeasureId,
    dynamic height,
    dynamic width,
    dynamic length,
    dynamic number,
    dynamic quantity,
  }) = UpdateToMeasurementLineEvent;
  // update view mode

  const factory MeasurementDetailBlocEvent.updateViewMode({
    required bool updateView,
  }) = UpdateViewModeEvent;

  // reset the sorlist

  const factory MeasurementDetailBlocEvent.cancelUpdate({
    required bool cancelUpdate,
  }) = CancelUpdateEvent;

  // submit

  const factory MeasurementDetailBlocEvent.submitLine({
    required dynamic noOfUnit,
    required dynamic cummulativePrevQty,
    required String sorId,
    required String type,
    int? index,
    int? measurementLineIndex,
    String? filteredMeasurementMeasureId,
  }) = SubmitLineEvent;
}

@freezed
class MeasurementDetailState with _$MeasurementDetailState {
  const MeasurementDetailState._();

  const factory MeasurementDetailState.initial() = _Initial;
  const factory MeasurementDetailState.loading() = _Loading;
  const factory MeasurementDetailState.loaded(
    String? warningMsg,
    bool viewStatus,
    Measurement rawData,
    List<FilteredMeasurements> data,
    List<SorObject>? sor,
    List<SorObject>? nonSor,
    List<SorObject>? preSor,
    List<SorObject>? preNonSor,
  ) = _Loaded;
  const factory MeasurementDetailState.error(String? error) = _Error;
}
