import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:munshiji/components/adaptive_text.dart';
import 'package:munshiji/components/drawer.dart';
import 'package:munshiji/globals.dart' as globals;
import 'package:munshiji/icons/vector_icons.dart';
import 'package:munshiji/models/category/category.dart';
import 'package:munshiji/providers/preference_provider.dart';
import 'package:munshiji/services/category_service.dart';
import 'package:munshiji/components/reorderable_list.dart' as Component;
import '../components/screen_size_config.dart';

import '../configuration.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  Lang language;
  String selectedSubSector;

  var _categoryName = TextEditingController();
  var _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceProvider>(
      builder: (context, preferenceProvider, _) {
        language = preferenceProvider.language;
        selectedSubSector =
            Provider.of<SubSectorProvider>(context).selectedSubSector;
        return Scaffold(
          backgroundColor: Configuration().appColor,
          drawer: MyDrawer(),
          appBar: AppBar(
            title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AdaptiveText('Categories'),
                  Flexible(
                      child: Text(' (' + selectedSubSector.toString() + ')'))
                ]),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddCategoryBottomSheet,
            child: Icon(Icons.add),
            backgroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  topRight: Radius.circular(50.0),
                ),
              ),
              padding:
                  EdgeInsets.only(top: ScreenSizeConfig.blockSizeVertical * 7),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
                          child: AdaptiveText(
                            'Cash Out',
                            style: TextStyle(
                                fontFamily: 'Source Sans Pro',
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 0),
                          child: AdaptiveText(
                            'Cash In',
                            style: TextStyle(
                                fontFamily: 'Source Sans Pro',
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
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
                      children: [CategoryType.EXPENSE, CategoryType.INCOME]
                          .map(
                            (categoryType) => _reorderableListView(
                              categoryType == CategoryType.EXPENSE
                                  ? globals.expenseCategories
                                  : globals.incomeCategories,
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
          future: CategoryService().getStockCategories(selectedSubSector, type),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var _disabledCategories = snapshot.data;
              categories.forEach((category) {
                _disabledCategories.removeWhere((dc) => dc.id == category.id);
              });
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: AdaptiveText(
                      'More categories',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 20.0,
                        color: _disabledCategories.length > 0
                            ? Colors.black
                            : Colors.grey,
                        fontWeight: _disabledCategories.length > 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  for (var categories in _disabledCategories)
                    Column(
                      children: <Widget>[
                        DecoratedBox(
                          key: Key('${categories.id}'),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.7))),
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
                                  AdaptiveText(
                                    '',
                                    category: categories,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 15,
                                      color: const Color(0xff272b37),
                                      height: 1.4285714285714286,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: InkWell(
                                splashColor: Colors.transparent,
                                onTap: () async {
                                  var categoryList = await CategoryService()
                                      .getCategories(selectedSubSector, type);
                                  if (!categoryList.contains(categories)) {
                                    await CategoryService().addCategory(
                                      selectedSubSector,
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
                        SizedBox(
                          height: 16,
                        )
                      ],
                    ),
                  SizedBox(
                    height: 40,
                  )
                ],
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

  Widget _reorderableListView(
      List<Category> categories, CategoryType categoryType) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Component.ReorderableListView(
        children: [
          for (int i = 0; i < categories.length; i++)
            Column(
              key: Key('$i'),
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey.withOpacity(0.7))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              VectorIcons.fromName(
                                categories[i].iconName,
                                provider: IconProvider.FontAwesome5,
                              ),
                              color: Configuration().incomeColor,
                              size: 20.0,
                            ),
                          ),
                          AdaptiveText(
                            '',
                            category: categories[i],
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              color: const Color(0xff272b37),
                              height: 1.4285714285714286,
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
                SizedBox(
                  height: 16,
                )
              ],
            ),
        ],
        footer: _disabledCategories(categories, categoryType),
        onReorder: _reorderCategoryList,
      ),
    );
  }

  Future _showDeleteDialog(int categoryId) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: AdaptiveText(
              'Warning',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            content: AdaptiveText(
              'Are you sure you want to delete this category? Deleting the category will also clear all the records related to it.',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            actions: <Widget>[
              SimpleDialogOption(
                child: AdaptiveText(
                  'DELETE',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onPressed: () async {
                  await CategoryService().deleteCategory(
                    selectedSubSector,
                    categoryId,
                    _tabController.index == 0
                        ? CategoryType.EXPENSE
                        : CategoryType.INCOME,
                  );
                  Navigator.pop(context);
                },
              ),
              SimpleDialogOption(
                child: AdaptiveText(
                  'CANCEL',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
    setState(() {});
  }

  Future _showAddCategoryBottomSheet() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    VectorIcons.fromName('hornbill',
                        provider: IconProvider.FontAwesome5),
                    color: Colors.grey,
                    size: 28,
                  ),
                  onPressed: () {},
                ),
                Text(
                  language == Lang.EN
                      ? 'Enter new category'
                      : 'नयाँ श्रेणी लेख्नुहोस',
                  style: TextStyle(color: Colors.black, fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.7)),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TextFormField(
                        validator: validator,
                        autofocus: true,
                        controller: _categoryName,
                        style:
                            TextStyle(color: Colors.grey[800], fontSize: 20.0),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(8.0),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        color: Configuration().incomeColor),
                    child: InkWell(
                      onTap: () async {
                        if (_formKey.currentState.validate()) {
                          await CategoryService().addCategory(
                            selectedSubSector,
                            Category(
                              en: _categoryName.text,
                              np: _categoryName.text,
                              iconName: 'hornbill',
                              id: _categoryName.text.hashCode,
                            ),
                            type: _tabController.index == 0
                                ? CategoryType.EXPENSE
                                : CategoryType.INCOME,
                          );
                          Navigator.pop(context);
                        }
                        _categoryName.clear();
                      },
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 18),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.add),
                            SizedBox(
                              width: 5,
                            ),
                            AdaptiveText(
                              'Add Category',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    setState(() {});
  }

  void _reorderCategoryList(int preIndex, int postIndex) {
    if (_tabController.index == 0) {
      Category temp = globals.expenseCategories[preIndex];
      globals.expenseCategories.removeAt(preIndex);
      globals.expenseCategories
          .insert(postIndex > preIndex ? postIndex - 1 : postIndex, temp);
      CategoryService().refreshCategories(
          selectedSubSector, globals.expenseCategories,
          type: CategoryType.EXPENSE);
    } else {
      Category temp = globals.incomeCategories[preIndex];
      globals.incomeCategories.removeAt(preIndex);
      globals.incomeCategories
          .insert(postIndex > preIndex ? postIndex - 1 : postIndex, temp);
      CategoryService().refreshCategories(
          selectedSubSector, globals.incomeCategories,
          type: CategoryType.INCOME);
    }
    setState(() {});
  }

  String validator(String value) {
    var _value = value.toLowerCase();
    var categories = _tabController.index == 0
        ? globals.expenseCategories
        : globals.incomeCategories;
    if (value.isEmpty) {
      return language == Lang.EN ? 'Category is empty' : 'श्रेणी खाली छ';
    } else if (categories.any((category) =>
        category.en.toLowerCase() == _value ||
        category.np.toLowerCase() == _value)) {
      return language == Lang.EN
          ? 'Category already exists!'
          : 'श्रेणी पहिल्यै छ';
    }
    return null;
  }
}
