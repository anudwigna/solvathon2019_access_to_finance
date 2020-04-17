import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saral_lekha/components/adaptive_text.dart';
import 'package:saral_lekha/components/drawer.dart';
import 'package:saral_lekha/globals.dart' as globals;
import 'package:saral_lekha/icons/vector_icons.dart';
import 'package:saral_lekha/models/category/category.dart';
import 'package:saral_lekha/providers/preference_provider.dart';
import 'package:saral_lekha/services/category_service.dart';
import 'package:saral_lekha/components/reorderable_list.dart' as Component;

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
            
        return Theme(
          data: Theme.of(context)
              .copyWith(canvasColor: Configuration().yellowColor),
          child: Container(
            decoration: Configuration().gradientDecoration,
            child: Scaffold(
              drawer: MyDrawer(),
              appBar: AppBar(
                title: AdaptiveText('Categories ('+selectedSubSector.toString()+')'),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(
                      child: AdaptiveText('Expense'),
                    ),
                    Tab(
                      child: AdaptiveText('Income'),
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: _showAddCategoryBottomSheet,
                child: Icon(Icons.add),
                backgroundColor: Colors.white,
              ),
              body: TabBarView(
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
        Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: AdaptiveText(
            'More categories',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 20.0),
        FutureBuilder<List<Category>>(
          future: CategoryService().getStockCategories(selectedSubSector, type),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var _disabledCategories = snapshot.data;
              categories.forEach((category) {
                _disabledCategories.removeWhere((dc) => dc.id == category.id);
              });
              return Column(
                children: <Widget>[
                  for (var category in _disabledCategories)
                    ListTile(
                      key: Key('${category.id}'),
                      leading: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            VectorIcons.fromName(category.iconName,
                                provider: IconProvider.FontAwesome5),
                            size: 16.0,
                          ),
                        ),
                      ),
                      title: AdaptiveText(
                        '',
                        category: category,
                      ),
                      trailing: Material(
                        color: Colors.white,
                        shape: CircleBorder(),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50.0),
                          splashColor: Colors.green,
                          onTap: () async {
                            var categoryList = await CategoryService()
                                .getCategories(selectedSubSector, type);
                            if (!categoryList.contains(category)) {
                              await CategoryService().addCategory(
                                selectedSubSector,
                                category,
                                type: type,
                                isStockCategory: true,
                              );
                              setState(() {});
                            }
                          },
                          child: Icon(
                            Icons.add_circle,
                            size: 20.0,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 80.0),
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
    return Component.ReorderableListView(
      children: [
        for (int i = 0; i < categories.length; i++)
          ListTile(
            key: Key('$i'),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.drag_handle,
                  color: Colors.white.withAlpha(80),
                ),
                SizedBox(width: 10.0),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      VectorIcons.fromName(categories[i].iconName,
                          provider: IconProvider.FontAwesome5),
                      size: 16.0,
                    ),
                  ),
                ),
              ],
            ),
            title: AdaptiveText(
              '',
              category: categories[i],
            ),
            trailing: Material(
              color: Colors.white,
              shape: CircleBorder(),
              child: InkWell(
                borderRadius: BorderRadius.circular(50.0),
                splashColor: Colors.red,
                onTap: () => _showDeleteDialog(categories[i].id),
                child: Icon(
                  Icons.remove_circle,
                  size: 20.0,
                  color: Colors.red,
                ),
              ),
            ),
          ),
      ],
      footer: _disabledCategories(categories, categoryType),
      onReorder: _reorderCategoryList,
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
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: Duration(milliseconds: 100),
          curve: Curves.decelerate,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            VectorIcons.fromName('hornbill',
                                provider: IconProvider.FontAwesome5),
                            color: Colors.black,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            validator: validator,
                            controller: _categoryName,
                            style: TextStyle(
                                color: Colors.grey[800], fontSize: 20.0),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: language == Lang.EN
                                  ? 'Enter new category'
                                  : 'नयाँ श्रेणी लेख्नुहोस',
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 20.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      gradient: LinearGradient(
                        colors: Configuration().gradientColors,
                        begin: FractionalOffset.centerLeft,
                        end: FractionalOffset.centerRight,
                      ),
                    ),
                    child: Material(
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
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: AdaptiveText(
                            'ADD',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20.0),
                          ),
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
