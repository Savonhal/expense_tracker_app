// ignore_for_file: must_be_immutable, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'main.dart';
import 'expenseRow.dart';

//Responsible for the screen of every Category
//When Changing screens, passes ExpenseList object as argument
//Works by displaying the respective ExpenseList object's list and categeoryName
class CategoryScreen extends StatefulWidget{
  static String routeName = '/categoryPage';
  late List<Expense> currentList;
  late ExpenseList currentCategory;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _ExpenseName = TextEditingController();
  final TextEditingController _ExpenseAmount = TextEditingController();
  final _formKeyName = GlobalKey<FormState>();
  final _formKeyAmount = GlobalKey<FormState>();
  
  void setCategory(ExpenseList mainCategory){
    widget.currentCategory = mainCategory;
  }
  void setList(List<Expense> listArg){
    widget.currentList = listArg;
  }
  void addExpense(String expenseName, double expenseAmount) async{
    setState(() {
      
      widget.currentCategory.list.add(Expense(expenseName, expenseAmount));
      
    });
    await saveList(widget.currentCategory);
  }
  void editExpense(Expense obj, String newName, double newAmount) async{
    setState(() {
      obj.setName(newName);
      obj.setAmount(newAmount);
    });
    await saveList(widget.currentCategory);
  }
  void archiveExpense(Expense toBeArchived) async{
    setState(() {
      archived.list.add(toBeArchived);
      widget.currentCategory.list.remove(toBeArchived);
      
    });
    await saveList(widget.currentCategory);
    await saveList(archived);
  }
  void deleteExpense(Expense toBeDeleted) async{
    setState(() {
      widget.currentCategory.list.remove(toBeDeleted);
    });
    await saveList(widget.currentCategory);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ExpenseList;
    setCategory(args);
    setList(args.list);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(args.categoryName),
      ),
      body: ListView(
        children: args.list.map((Expense expense){
          return expenseRow(
            category: args,
            expense: expense, 
            editExpense: displayDialog, //Accesses dialog box
            archiveExpense: archiveExpense, 
            deleteExpense: deleteExpense);
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => displayDialog(Expense('name', 0), "add"),
        tooltip: 'Add Expense To list',
        child: const Icon(Icons.add_box)
      ),
    );
  }

  //Dialog box for when we add to ExpenseList's list
  Future<void> displayDialog(Expense exp, String type) async{
    return showDialog<void>(
      context: this.context, 
      builder: (BuildContext context){
        return AlertDialog(
          title: const Text(
            'Add / Edit your expense here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 10, 102, 13),
            ),
          ),
          content: Column(
            children: <Widget>[
              Form(
                key: _formKeyName,
                child:TextFormField(
                  controller: _ExpenseName,
                  validator: (value) {
                    if(value == null || value.isEmpty){
                       return 'Please enter a name for your expense';
                    }else{
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    hintText:"Expense Name",
                    hintStyle: const TextStyle(fontSize: 14),
                    icon: const Icon(Icons.list),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Form(
                key: _formKeyAmount,
                child: TextFormField(
                  controller: _ExpenseAmount,
                  validator: (value) {
                    if(value == null || value.isEmpty || double.tryParse(value).runtimeType != double){
                      return 'Please enter a valid number for your amount';
                    }else{
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    hintText:"Amount",
                    hintStyle: const TextStyle(fontSize: 14),
                    icon: const Icon(Icons.monetization_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    )
                  ),
                ),
              )
            ],
          ),
          actions: <Widget>[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape:RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
                )
              ),
              onPressed: (){
                if (_formKeyName.currentState!.validate() && _formKeyAmount.currentState!.validate()) {
                  if((type == 'add')){
                    addExpense(_ExpenseName.text, double.parse(_ExpenseAmount.text));
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added ${_ExpenseName.text} to ${widget.currentCategory.categoryName}')),
                    );
                     _ExpenseName.clear();
                     _ExpenseAmount.clear();
                  }else if(type == 'edit'){
                    
                    editExpense(exp, _ExpenseName.text, double.parse(_ExpenseAmount.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Edited an expense in ${widget.currentCategory.categoryName}')),
                    );
                  }
                  
                  Navigator.of(context).pop();
                }
              }, 
              child: const Text('Save')
            ),
            ElevatedButton(
              style:OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
                )
              ),
              onPressed: (){
                Navigator.of(context).pop();
              }, 
              child: const Text('Cancel')
            )
          ],
        );
      }
    );
  }


}