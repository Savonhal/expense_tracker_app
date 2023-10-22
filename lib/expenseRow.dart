import 'package:flutter/material.dart';
import 'main.dart';

//Class that is responsible for the GUI of row items in _CategoryScreenState
//Called in build method and used to map the ExpenseList's list
class expenseRow extends StatelessWidget{
  expenseRow({
    required this.category,
    required this.expense,
    required this.editExpense,
    required this.archiveExpense,
    required this.deleteExpense
  }): super(key: ObjectKey(expense));

  final ExpenseList category;
  final Expense expense;
  final void Function(Expense expense, String type) editExpense;
  final void Function(Expense expense) archiveExpense;
  final void Function(Expense expense) deleteExpense;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconButton(
        onPressed: (){
          //Dialog box
          editExpense(expense, 'edit');
        }, 
        icon: const Icon(
          Icons.edit,
          color: Colors.yellow,
        )
      ),
      title: Row(
        children: <Widget>[
          Expanded(child: Text(expense.getName())),
          Expanded(child: Text('\$${expense.getAmount()}')),
          IconButton(
            onPressed: (){
              archiveExpense(expense);
            }, 
            icon: Icon(
              category.categoryName == 'Archived' ? 
                null : Icons.archive,
              color: Colors.orange,
              )
            ),
          IconButton(
            onPressed:() {
              deleteExpense(expense);
              }, 
            icon: Icon(
              Icons.delete,
              color: Colors.grey[850],
            )
            ),
        ]
        
      )
    );
  }

}