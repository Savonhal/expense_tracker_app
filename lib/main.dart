import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'CategoryScreen.dart';

//DO NOT EDIT the main.g.dart file, it will mess with the saving feature
part 'main.g.dart';

//These are the lists that are displayed on the their respective pages
ExpenseList archived = ExpenseList('Archived');
ExpenseList billsAndUtilities = ExpenseList('Bills / Utilities');
ExpenseList foodAndGroceries = ExpenseList('Food / Groceries');
ExpenseList entertainment = ExpenseList('Entertainment');
ExpenseList shopping = ExpenseList('Shopping');
ExpenseList other = ExpenseList('Other');

//List composed of the ExpenseList objects above; Used for for loop in void main() below
List<ExpenseList> expenseListCategories = [archived,billsAndUtilities,foodAndGroceries,entertainment,shopping,other];

void main() async{
  //Load ExpenseLists from previously saved data stored in SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  for(ExpenseList category in expenseListCategories){
    final savedExpenseListJson = prefs.getString(category.categoryName);
    if(savedExpenseListJson != null){
      final loadedExpenseList = ExpenseList.fromJson(jsonDecode(savedExpenseListJson));
      category.list = loadedExpenseList.list;
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routes:{
        CategoryScreen.routeName:(context) => CategoryScreen()
      },
      home: const MyHomePage(title: 'Expense Tracker Page'),
    );
  }
}

//Call this function everytime we add, edit, archive, or delete something in the ExpenseList object's list
Future<void> saveList(ExpenseList list) async{
    final prefs = await SharedPreferences.getInstance();
    final expenseListJson = list.toJson();
    await prefs.setString(list.categoryName , jsonEncode(expenseListJson) );
  }

//Class thta creates Expense Objects
@JsonSerializable()
class Expense {
  String name;
  double amount;
   
  Expense(this.name, this.amount);

  void setName(String newName) {
    name = newName;
  }

  String getName() {
    return name;
  }

  void setAmount(double newAmount) {
    amount = newAmount;
  }

  double getAmount() {
    return amount;
  }

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);

}

//Class that holds the category names and list of Expense objects
@JsonSerializable()
class ExpenseList{
  String categoryName;
  List<Expense> list = [];
  
  ExpenseList(this.categoryName);

  factory ExpenseList.fromJson(Map<String, dynamic> json) => _$ExpenseListFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseListToJson(this);

}

//Function that returns the cumulative sum of ExpenseList list's amount
double updateSumAmount(List<Expense> list){
    double sumAmount = 0;
    for(Expense exp in list){
      sumAmount = sumAmount + exp.amount;
    }
    return sumAmount;
  }

//This is the homepage or main screen of the app
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _userInputBudget = TextEditingController(); 
  double allocatedBudget=0;
  double amountSpent = 0;
  double amountLeft = 0;
 
  double amountLeftPercent = 0;
  double categoryPercent = 0;

  @override
  void initState(){
    super.initState();
    updateUIValues();
  }
  void calculateAmountSpent(){
    amountSpent = 0;
    for(ExpenseList mainCategory in expenseListCategories){
      if(mainCategory.list.isNotEmpty && mainCategory.categoryName != 'Archived'){
        amountSpent = amountSpent + updateSumAmount(mainCategory.list);
      }
    }
    
  }
  void calculateAmountLeft(){
    amountLeft = allocatedBudget - amountSpent;
  }
  double calculateAmountLeftPercentage(){
    return ( amountLeft <= 0?  0.0 :amountLeftPercent = amountLeft/allocatedBudget * 100 * 0.01);
  }
  double calculateCategoryPercentage(ExpenseList mainCategory){
    return (amountLeft <= 0 ? 0.0 : updateSumAmount(mainCategory.list)/allocatedBudget * 100 * 0.01);
  }
  void updateUIValues()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("allocatedBudget")) {
      allocatedBudget = prefs.getDouble("allocatedBudget")!;
    }
     
    setState(() {
      calculateAmountSpent();
      calculateAmountLeft();
      calculateAmountLeftPercentage();
      saveBudget();
    });
                        
  }
  void saveBudget() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    prefs.setDouble("allocatedBudget", allocatedBudget);
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, 
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title, style:const TextStyle(fontWeight: FontWeight.bold)),
       
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
           const SizedBox(height:5),
           Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
             children: [
              CircularPercentIndicator(
                radius: 75,
                percent: amountLeftPercent = calculateAmountLeftPercentage(),
                backgroundColor: Colors.red,
                progressColor: Colors.green,
                lineWidth: 15,
                animation: true,
                animateFromLastPercent: true,
                animationDuration: 500,
                center: Text('${((calculateAmountLeftPercentage())* 100).toStringAsFixed(2) }%', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
                footer: Text('Amount Left: \$ ${amountLeft.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width:20),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 45,
                    width: 200,
                    child: TextFormField(
                    controller: _userInputBudget,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter New Total Budget',
                      hintStyle: const TextStyle(fontSize: 15),
                      filled: true,
                      fillColor: Color.fromARGB(255, 85, 166, 113),
                      //icon: const Icon(Icons.monetization_on_outlined),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onFieldSubmitted: (value) {
                      if(value.runtimeType == double){
                        allocatedBudget = double.parse(value);
                      }
                        _userInputBudget.clear();
                      
                      setState(() {
                        calculateAmountSpent();
                        calculateAmountLeft();
                        calculateAmountLeftPercentage();
                        saveBudget();
                      
                      });
                    },
                   ),
                  ),
                  Text('Your Budget: \$$allocatedBudget',style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('Amount Spent: \$$amountSpent',style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              const SizedBox(width:10),
             ],
           ),
           const SizedBox(
            height: 10,
           ),
          const Row(
            children: [
              SizedBox(width:180),
              Text('Amount | Percent'),
            ],
          ),
           ListTile(
            title: Row(
              children: <Widget>[
                const Expanded(child:Text('Bills/Utilities')),
                Text('\$${updateSumAmount(billsAndUtilities.list).toStringAsFixed(2)} '),
                const SizedBox(width:7),
                CircularPercentIndicator(
                  radius: 15,
                  percent:calculateCategoryPercentage(billsAndUtilities),
                  footer: Text('${(calculateCategoryPercentage(billsAndUtilities)*100).toStringAsFixed(2)}%'),
                ),
                const SizedBox(width:7),
                ElevatedButton(
                  onPressed: (){
                    Navigator.pushNamed(
                      context, CategoryScreen.routeName,
                      arguments: billsAndUtilities,
                    ).then((value)=> setState((){updateUIValues();}));
                  },
                  child:const Icon(Icons.keyboard_control)
                ),
              ],
            ),
           ),
           ListTile(
            title: Row(
              children: <Widget>[
                const Expanded (child:Text('Food/Groceries')),
                Text('\$${updateSumAmount(foodAndGroceries.list).toStringAsFixed(2)} '),
                const SizedBox(width:7),
                CircularPercentIndicator(
                  radius: 15,
                  percent:calculateCategoryPercentage(foodAndGroceries),
                  footer: Text('${(calculateCategoryPercentage(foodAndGroceries)*100).toStringAsFixed(2)}%'),
                ),
                const SizedBox(width:7),
                ElevatedButton(
                  onPressed: (){
                    Navigator.pushNamed(
                      context, CategoryScreen.routeName,
                      arguments: foodAndGroceries,
                    ).then((value)=> setState((){updateUIValues();}));
                  },
                  child:const Icon(Icons.keyboard_control)
                ),
              ],
            ),
           ),
           ListTile(
            title: Row(
              children: <Widget>[
                const Expanded(child:Text('Entertainment')),
                 Text('\$${updateSumAmount(entertainment.list).toStringAsFixed(2)} '),
                const SizedBox(width:7),
                CircularPercentIndicator(
                  radius: 15,
                  percent:calculateCategoryPercentage(entertainment),
                  footer: Text('${(calculateCategoryPercentage(entertainment)*100).toStringAsFixed(2)}%'),
                ),
                const SizedBox(width:7),
                ElevatedButton(
                  onPressed: (){
                    Navigator.pushNamed(
                      context, CategoryScreen.routeName,
                      arguments: entertainment,
                    ).then((value)=> setState((){updateUIValues();}));
                  },
                  child:const Icon(Icons.keyboard_control)
                ),
              ],
            ),
           ),
           ListTile(
            title: Row(
              children: <Widget>[
                const Expanded(child:Text('Shopping')),
                 Text('\$${updateSumAmount(shopping.list).toStringAsFixed(2)} '),
                const SizedBox(width:7),
                CircularPercentIndicator(
                  radius: 15,
                  percent:calculateCategoryPercentage(shopping),
                  footer: Text('${(calculateCategoryPercentage(shopping)*100).toStringAsFixed(2)}%'),
                ),
                const SizedBox(width:7),
                ElevatedButton(
                 onPressed: (){
                    Navigator.pushNamed(
                      context, CategoryScreen.routeName,
                      arguments: shopping,
                    ).then((value)=> setState((){updateUIValues();}));
                  },
                  child:const Icon(Icons.keyboard_control)
                ),
              ],
            ),
           ),
           ListTile(
            title: Row(
              children: <Widget>[
                const Expanded(child:Text('Other')),
                 Text('\$${updateSumAmount(other.list).toStringAsFixed(2)} '),
                const SizedBox(width:7),
                CircularPercentIndicator(
                  radius: 15,
                  percent:calculateCategoryPercentage(other),
                  footer: Text('${(calculateCategoryPercentage(other)*100).toStringAsFixed(2)}%'),
                ),
                const SizedBox(width:7),
                ElevatedButton(
                  onPressed: (){
                    Navigator.pushNamed(
                      context, CategoryScreen.routeName,
                      arguments: other,
                    ).then((value)=> setState((){updateUIValues();}));
                  },
                  child:const Icon(Icons.keyboard_control)
                ),
              ],
            ),
            
           ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
            onPressed: (){
              Navigator.pushNamed(
                context, CategoryScreen.routeName,
                arguments: archived,
              ).then((value)=> setState((){updateUIValues();}));
            },
            label: const Text(
              'Archived Expenses',
              style: TextStyle(fontSize: 10, color: Colors.black),
            )
          ),
    );
  }
}

