import 'package:MunshiG/components/adaptive_text.dart';
import 'package:MunshiG/components/drawer.dart';
import 'package:MunshiG/components/reorderable_list.dart' as Component;
import 'package:MunshiG/config/globals.dart' as globals;
import 'package:MunshiG/icons/vector_icons.dart';
import 'package:MunshiG/models/category/category.dart';
import 'package:MunshiG/providers/preference_provider.dart';
import 'package:MunshiG/services/category_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../components/extra_componenets.dart';
import '../components/screen_size_config.dart';
import '../config/configuration.dart';
import '../config/globals.dart';
import '../models/app_page_naming.dart';
import '../models/categoryHeading/categoryHeading.dart';
import '../screens/transaction_page.dart';
import '../services/activity_tracking.dart';
import '../services/category_heading_service.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  TabController? _tabController;
  Lang? language;
  String? selectedSubSector;
  var _categoryName = TextEditingController();
  var _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ActivityTracker().pageTransactionActivity(PageName.categories, action: 'Opened');
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        ActivityTracker().pageTransactionActivity(PageName.categories, action: 'Paused');
        break;
      case AppLifecycleState.inactive:
        ActivityTracker().pageTransactionActivity(PageName.categories, action: 'Inactive');
        break;
      case AppLifecycleState.resumed:
        ActivityTracker().pageTransactionActivity(PageName.categories, action: 'Resumed');
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ActivityTracker().pageTransactionActivity(PageName.categories, action: 'Closed');
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceProvider>(
      builder: (context, preferenceProvider, _) {
        language = preferenceProvider.language;
        selectedSubSector = Provider.of<SubSectorProvider>(context).selectedSubSector;
        return Scaffold(
          backgroundColor: Configuration().appColor,
          drawer: MyDrawer(),
          appBar: AppBar(
            title: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              AdaptiveText(
                'Categories',
                style: TextStyle(fontSize: 17),
              ),
              Text(
                ' (',
                style: TextStyle(fontSize: 17),
              ),
              AdaptiveText(
                selectedSubSector.toString(),
                style: TextStyle(fontSize: 17),
              ),
              Text(
                ')',
                style: TextStyle(fontSize: 17),
              ),
            ]),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if ((await showDialog(
                    context: context,
                    builder: (context) => Consumer<PreferenceProvider>(
                      builder: (context, value, child) => CategoryDialog(
                        isCashIn: _tabController!.index == 0,
                      ),
                    ),
                  )) ??
                  false) {
                setState(() {});
              }
            },
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 27,
            ),
            backgroundColor: Configuration().incomeColor,
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 23.0),
            child: Container(
              decoration: pageBorderDecoration,
              padding: EdgeInsets.only(top: 30),
              child: Column(
                children: <Widget>[
                  TabBar(
                    isScrollable: true,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Configuration().incomeColor,
                    ),
                    controller: _tabController,
                    unselectedLabelColor: Colors.black,
                    labelColor: Colors.white,
                    tabs: [
                      Tab(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                          child: AdaptiveText(
                            'Cash In',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          child: AdaptiveText(
                            'Cash Out',
                            style: TextStyle(fontFamily: 'Source Sans Pro', fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenSizeConfig.blockSizeVertical * 5,
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [CategoryType.INCOME, CategoryType.EXPENSE]
                          .map(
                            (categoryType) => _reorderableListView(
                              categoryType == CategoryType.EXPENSE ? globals.expenseCategories! : globals.incomeCategories!,
                              categoryType,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _disabledCategories(List<Category> categories, CategoryType type) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FutureBuilder<List<Category>>(
          future: CategoryService().getStockCategories(selectedSubSector!, type),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var _disabledCategories = snapshot.data!;
              categories.forEach((category) {
                _disabledCategories.removeWhere((dc) => dc.id == category.id);
              });
              if (_disabledCategories.isNotEmpty)
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AdaptiveText(
                      'More Categories',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: _disabledCategories.length > 0 ? Colors.black : Colors.grey,
                        fontWeight: _disabledCategories.length > 0 ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _disabledCategories.length,
                      itemBuilder: (BuildContext context, int index) {
                        final categories = _disabledCategories[index];
                        return Padding(
                          key: Key('${categories.id}'),
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: DecoratedBox(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.withOpacity(0.7))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                title: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        VectorIcons.fromName(
                                          categories.iconName,
                                          provider: IconProvider.FontAwesome5,
                                        ),
                                        color: Configuration().incomeColor,
                                        size: 20.0,
                                      ),
                                    ),
                                    Flexible(
                                      child: AdaptiveText(
                                        '',
                                        category: categories,
                                        style: TextStyle(
                                          fontFamily: 'SourceSansPro',
                                          fontSize: 15,
                                          color: const Color(0xff272b37),
                                          height: 1.4285714285714286,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: InkWell(
                                  splashColor: Colors.transparent,
                                  onTap: () async {
                                    var categoryList = await CategoryService().getCategories(selectedSubSector!, type);
                                    if (!categoryList.contains(categories)) {
                                      await CategoryService().addCategory(
                                        selectedSubSector!,
                                        categories,
                                        type: type,
                                        isStockCategory: true,
                                      );
                                      setState(() {});
                                    }
                                  },
                                  child: Icon(
                                    Icons.add_circle,
                                    size: 30.0,
                                    color: Color(0xffB581F6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: 40,
                    )
                  ],
                );
              return SizedBox(
                height: 1,
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _reorderableListView(List<Category> categories, CategoryType categoryType) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Component.ReorderableListView(
        children: [
          for (int i = 0; i < categories.length; i++)
            Padding(
              key: Key('$i'),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.grey.withOpacity(0.7))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: ListTile(
                    title: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FutureBuilder<CategoryHeading?>(
                            future: CategoryHeadingService()
                                .getCategoryHeadingById(categoryType, categories[i].categoryHeadingId == null ? (categoryType == CategoryType.INCOME ? 100 : 1) : categories[i].categoryHeadingId),
                            builder: (BuildContext context, AsyncSnapshot<CategoryHeading?> snapshot) {
                              return (!snapshot.hasData)
                                  ? Icon(
                                      VectorIcons.fromName(
                                        'hornbill',
                                        provider: IconProvider.FontAwesome5,
                                      ),
                                      color: Configuration().incomeColor,
                                      size: 20.0,
                                    )
                                  : SvgPicture.asset('assets/images/${snapshot.data!.iconName}');
                            },
                          ),
                        ),
                        Flexible(
                          child: AdaptiveText(
                            '',
                            category: categories[i],
                            style: TextStyle(
                              fontFamily: 'SourceSansPro',
                              fontSize: 14,
                              color: const Color(0xff272b37),
                              height: 1.4285714285714286,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: InkWell(
                      splashColor: Colors.transparent,
                      onTap: () => _showDeleteDialog(categories[i].id),
                      child: Icon(
                        Icons.remove_circle,
                        size: 30.0,
                        color: Color(0xffB581F6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
        footer: _disabledCategories(categories, categoryType),
        onReorder: _reorderCategoryList,
      ),
    );
  }

  Future _showDeleteDialog(int? categoryId) async {
    await showDeleteDialog(context, title: 'Delete Category', description: '''Are you sure you want to delete this category? Deleting the category will also clear all the records related to it.''',
        onDeletePress: () async {
      await CategoryService().deleteCategory(selectedSubSector!, categoryId, _tabController!.index == 0 ? CategoryType.INCOME : CategoryType.EXPENSE, false);
      Navigator.of(context, rootNavigator: true).pop(true);
    }, onCancelPress: () {
      Navigator.of(context, rootNavigator: true).pop(false);
    }).then((value) {
      if (value ?? false) {
        setState(() {});
      }
    });
  }

  void _reorderCategoryList(int preIndex, int postIndex) {
    if (_tabController!.index == 0) {
      Category temp = globals.expenseCategories![preIndex];
      globals.expenseCategories!.removeAt(preIndex);
      globals.expenseCategories!.insert(postIndex > preIndex ? postIndex - 1 : postIndex, temp);
      CategoryService().refreshCategories(selectedSubSector!, globals.expenseCategories!, type: CategoryType.INCOME);
    } else {
      Category temp = globals.incomeCategories![preIndex];
      globals.incomeCategories!.removeAt(preIndex);
      globals.incomeCategories!.insert(postIndex > preIndex ? postIndex - 1 : postIndex, temp);
      CategoryService().refreshCategories(selectedSubSector!, globals.incomeCategories!, type: CategoryType.EXPENSE);
    }
    setState(() {});
  }

  String? validator(String value) {
    var _value = value.toLowerCase();
    var categories = _tabController!.index == 0 ? globals.expenseCategories : globals.incomeCategories;
    if (value.isEmpty) {
      return language == Lang.EN ? 'Category is empty' : 'श्रेणी खाली छ';
    } else if (categories!.any((category) => category.en!.toLowerCase() == _value || category.np!.toLowerCase() == _value)) {
      return language == Lang.EN ? 'Category already exists!' : 'श्रेणी पहिल्यै छ';
    }
    return null;
  }
}

class CategoryDialog extends StatefulWidget {
  final bool? isCashIn;

  const CategoryDialog({Key? key, this.isCashIn}) : super(key: key);
  @override
  _CategoryDialogState createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  int? categoryHeadingId;
  var categoryName = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  Lang? language;
  List<CategoryHeading>? categoryHeading;
  @override
  void initState() {
    CategoryHeadingService().getAllCategoryHeadings(widget.isCashIn! ? CategoryType.INCOME : CategoryType.EXPENSE).then((value) {
      setState(() {
        categoryHeading = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    language = Provider.of<PreferenceProvider>(context).language;
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.white),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18.0))),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 23),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              SvgPicture.string(
                                userLogo,
                                allowDrawingOutsideViewBox: true,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              AdaptiveText(
                                'Category Heading',
                                style: TextStyle(
                                  fontFamily: 'SourceSansPro',
                                  fontSize: 16,
                                  color: const Color(0xff43425d),
                                  height: 1.5625,
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: double.maxFinite,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField(
                                decoration: InputDecoration.collapsed(
                                  hintText: '',
                                ),
                                validator: (dynamic value) {
                                  if (categoryHeadingId == null) return language == Lang.EN ? 'Category Heading cannot be empty' : 'श्रेणी शीर्षक खाली हुन सक्दैन';
                                  return null;
                                },
                                onTap: () {
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                },
                                value: categoryHeadingId,
                                isExpanded: true,
                                isDense: false,
                                style: TextStyle(color: Colors.black, fontSize: 17.0),
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey,
                                ),
                                items: (categoryHeading ?? [])
                                    .map((heading) => DropdownMenuItem(
                                          child: dropDownMenuBuilder(
                                              VectorIcons.fromName(
                                                'hornbill',
                                                provider: IconProvider.FontAwesome5,
                                              ),
                                              language == Lang.EN ? heading.en : heading.np,
                                              iconBuilderWidget: SvgPicture.asset('assets/images/' + heading.iconName!)),
                                          value: heading.id,
                                        ))
                                    .toList(),
                                onChanged: (dynamic value) {
                                  setState(() {
                                    categoryHeadingId = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: <Widget>[
                              SvgPicture.string(
                                userLogo,
                                allowDrawingOutsideViewBox: true,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              AdaptiveText(
                                'Category Name',
                                style: TextStyle(
                                  fontFamily: 'SourceSansPro',
                                  fontSize: 16,
                                  color: const Color(0xff43425d),
                                  height: 1.5625,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: TextFormField(
                              validator: validator,
                              controller: categoryName,
                              style: TextStyle(color: Colors.grey[800], fontSize: 20.0),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25.0),
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(30.0)), color: Configuration().incomeColor),
                  child: InkWell(
                    onTap: _addCategory,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 18),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.add,
                            size: 20,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          AdaptiveText(
                            'Add' + ' ' + (widget.isCashIn! ? 'Cash In' : 'Cash Out'),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 17.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _addCategory() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (_formKey.currentState!.validate()) {
      await CategoryService().addCategory(
        selectedSubSector!,
        Category(en: categoryName.text, np: categoryName.text, iconName: 'hornbill', id: categoryName.text.hashCode, categoryHeadingId: categoryHeadingId),
        type: widget.isCashIn! ? CategoryType.INCOME : CategoryType.EXPENSE,
      );
      categoryName.clear();
      Navigator.of(context, rootNavigator: true).pop(true);
    }
  }

  String? validator(String? value) {
    var _value = value!.toLowerCase();
    var categories = widget.isCashIn! ? globals.incomeCategories : globals.expenseCategories;
    if (value.isEmpty) {
      return language == Lang.EN ? 'Category cannot be empty' : 'श्रेणी खाली हुन सक्दैन';
    } else if (categories!.any((category) => category.en!.toLowerCase() == _value || category.np!.toLowerCase() == _value)) {
      return language == Lang.EN ? 'Category already exists!' : 'श्रेणी पहिल्यै छ';
    }
    return null;
  }
}
