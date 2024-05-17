import 'package:digit_components/digit_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:works_shg_app/blocs/employee/mb/measurement_book.dart';
import 'package:works_shg_app/blocs/employee/work_order/workorder_book.dart';
import 'package:works_shg_app/blocs/localization/app_localization.dart';
import 'package:works_shg_app/blocs/organisation/org_search_bloc.dart';
import 'package:works_shg_app/blocs/wage_seeker_registration/wage_seeker_location_bloc.dart';
import 'package:works_shg_app/models/organisation/organisation_model.dart';

import 'package:works_shg_app/router/app_router.dart';
import 'package:works_shg_app/utils/common_methods.dart';
import 'package:works_shg_app/utils/employee/support_services.dart';
import 'package:works_shg_app/utils/global_variables.dart';
import 'package:works_shg_app/widgets/SideBar.dart';
import 'package:works_shg_app/widgets/atoms/app_bar_logo.dart';
import 'package:works_shg_app/widgets/atoms/radio_button_list.dart';

import 'package:works_shg_app/utils/localization_constants/i18_key_constants.dart'
    as i18;

import '../../../widgets/drawer_wrapper.dart';

class WOFilterPage extends StatefulWidget {
  const WOFilterPage({super.key});

  @override
  State<WOFilterPage> createState() => _WOFilterPageState();
}

class _WOFilterPageState extends State<WOFilterPage> {
  List<OrganisationModel>? orgId; // Initialize ward list
  // List<statusMap.StatusMap> workflow = []; // Initialize workflow list

  TextEditingController woNumber = TextEditingController();
  TextEditingController projectId = TextEditingController();
  TextEditingController projectName = TextEditingController();
  bool workShow = true;
  bool project = true;

  String orgNumberKey = 'gender';
  String genderController = '';
  @override
  void initState() {
    super.initState();

    woNumber.addListener(mbNumberUpload);
    projectId.addListener(projectIdUpload);
    projectName.addListener(projectNameUpload);
  }

  void mbNumberUpload() {
    if (woNumber.text != "" || projectId.text != "" || projectName.text != "") {
      setState(() {
        workShow = false;
      });
    } else {
      setState(() {
        workShow = true;
      });
    }
  }

  void projectIdUpload() {
    if (woNumber.text != "" || projectId.text != "" || projectName.text != "") {
      setState(() {
        workShow = false;
      });
    } else {
      setState(() {
        workShow = true;
      });
    }
  }

  void projectNameUpload() {
    if (woNumber.text != "" || projectId.text != "" || projectName.text != "") {
      setState(() {
        workShow = false;
      });
    } else {
      setState(() {
        workShow = true;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    woNumber.removeListener(mbNumberUpload);
    projectId.removeListener(projectIdUpload);
    projectName.removeListener(projectNameUpload);

    woNumber.dispose();
    projectId.dispose();
    projectName.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context);

    return BlocBuilder<ORGSearchBloc, ORGSearchState>(
      builder: (context, state) {
        return state.maybeWhen(
          orElse: () {
            return const SizedBox.shrink();
          },
          loaded: (location) {
            return Scaffold(
              appBar: AppBar(
                titleSpacing: 0,
                title: const AppBarLogo(),
              ),
              drawer: DrawerWrapper(
                Drawer(
                  child: SideBar(
                    module: CommonMethods.getLocaleModules(),
                  ),
                ),
              ),
              body: ReactiveFormBuilder(
                  form: detailBuildForm,
                  builder: (BuildContext context, FormGroup formGroup,
                      Widget? child) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ScrollableContent(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        footer: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: DigitOutLineButton(
                                  label: t.translate(i18.measurementBook.clear),
                                  onPressed: () {
                                    context.router.pop();
                                  },
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: DigitElevatedButton(
                                  child: Text(
                                      t.translate(i18.measurementBook.filter)),
                                  onPressed: () async {
                                    Map<String, dynamic> s;
                                    String? k;
                                    if (formGroup.value[orgNumberKey] != null) {
                                      OrganisationModel data =
                                          formGroup.value[orgNumberKey]!
                                              as OrganisationModel;
                                      k = data.orgNumber;
                                    }

                                    s = {
                                      "tenantId": GlobalVariables.tenantId ??
                                          GlobalVariables.organisationListModel!
                                              .organisations!.first.tenantId,
                                      "contractNumber": woNumber.text,
                                      // "orgIds": orgId != null
                                      //     ? orgId!
                                      //         .map((e) => e.orgNumber)
                                      //         .toList()
                                      //     : [],
                                      "orgIds": k != null ? [k] : [],
                                      "wfStatus": ["ACCEPTED"],
                                      "pagination": {
                                        "limit": "10",
                                        "offSet": 0,
                                        "sortBy": "lastModifiedTime",
                                        "order": "desc"
                                      }
                                    };

                                    context.read<WorkOrderInboxBloc>().add(
                                        WorkOrderInboxSearchBlocEvent(
                                            data: s, limit: 10, offset: 0));
                                    context.router.pop();
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    context.router.pop();
                                  },
                                  icon: const Icon(Icons.close)),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(Icons.filter_alt),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  t.translate(i18.measurementBook.filter),
                                  style: DigitTheme.instance.mobileTheme
                                      .textTheme.headlineLarge,
                                ),
                              ),
                            ],
                          ),

                          DigitTextField(
                             label: t.translate(i18.measurementBook.workOrderNumber),
                            // label: "Work Order Number",
                            controller: woNumber,
                          ),

                          // DigitDropdown<OrganisationModel>(
                          //   onChanged: (value) {
                          //     if (orgId != null) {
                          //       setState(() {
                          //         orgId!.add(value!);
                          //         project = false;
                          //       });
                          //     } else {
                          //       orgId = [];
                          //       if (orgId != null) {
                          //         setState(() {
                          //           orgId!.add(value!);
                          //           project = false;
                          //         });
                          //       }
                          //     }
                          //   },
                          //   value: (orgId != null && orgId!.isNotEmpty)
                          //       ? orgId!.first
                          //       : null,
                          //   //value: null,
                          //   label: "Organization Name",
                          //   // label: t.translate(i18.common.orgSubType),
                          //   // menuItems: location!
                          //   //     .tenantBoundaryList!
                          //   //     .first
                          //   //     .boundaryList!
                          //   //     .map((e) => e.code.toString())
                          //   //     .toList(),
                          //   menuItems:
                          //       location!.organisations!.map((e) => e).toList(),
                          //   valueMapper: (value) {
                          //     return value.name!;
                          //     // return value.toString();
                          //   },
                          // )

                          DigitSearchDropdown<OrganisationModel>(
                            suggestionsCallback: (items, pattern) {
                              return items
                                  .where((obj) => obj.name!.contains(pattern))
                                  .toList();
                            },
                            label: "Organization Name",
                            menuItems:
                                location!.organisations!.map((e) => e).toList(),
                            formControlName: orgNumberKey,
                            valueMapper: (value) {
                              return value.name!;
                            },
                          ),
                        ],
                      ),
                    );
                  }),
            );
          },
        );
      },
    );
  }

  FormGroup detailBuildForm() => fb.group(<String, Object>{
        orgNumberKey: FormControl<OrganisationModel>(value: null),
      });

  String convertToWard(String input) {
    String tenant = Conversion.splitTenant(GlobalVariables.tenantId!);
    String result = "${tenant}_ADMIN_${input.toUpperCase()}";
    return result;
  }
}
