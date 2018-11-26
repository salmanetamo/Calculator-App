/*
Author: Salmane Tamo
Date: 18/11/2018

Description: This renders the calculator application and allows for the different interactions.
*/


import 'package:flutter/material.dart';
import './infix_operator.dart';

/*
StatefulWidget class to create a CalculatorState object
*/
class Calculator extends StatefulWidget {

  @override
  _CalculatorState createState() => new _CalculatorState();
}


/*
The CalculatorState class contains all the different components of the calculator.
It also ensures the values enntered are valid for calculation.
*/
class _CalculatorState extends State<Calculator> {
  //This the list of all the buttons needed for our calculator
  List<String> _buttonValues = ["C", "7", "4", "1", ".",
                              "()", "8", "5", "2", "0",
                              "-", "9", "6", "3", "DEL",
                              "/", "*", "+", "="];

  //List of the non-numerical buttons in the calculator
  List<String> _operators = ["C", "()", "-", "/", "*", "+", "="];

  //List of the different numerical buttons 
  List<String> _digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  //This stores the operation to be performed as a string
  String _operation = '';

  /*
  This method updates the operation by adding to the operation the value 
  of the button that was clicked provided that it is a valid input.

  Parameter: pressedButtonValue: value of the button that has been pressed
  */
  void _addToOperation(String pressedButtonValue) {
    setState(() {
      if(pressedButtonValue == _operators[1]){
        //When the brackets button is pressed
        onBracketsPressed();
      } else if(_operators.sublist(2, _operators.length).contains(pressedButtonValue)) {
        //When one of the four operators is pressed

        //Make sure the operation is not empty and 
        //the current last element is a number or a closing bracket before adding
        if(_operation.length != 0 &&
            (_digits.contains(_operation[_operation.length - 1]) ||
                _operation[_operation.length - 1] == ')')){
          _operation += pressedButtonValue;
        }
        //This is to ensure we can enter negative numbers
        if(pressedButtonValue == '-' && 
        (_operation.length == 0 || _operation[_operation.length - 1] == '(')){
          _operation += pressedButtonValue;
        }
      } else if(pressedButtonValue == '.'){
        //When the dot is pressed for a decimal number
        onPointPressed();
      } else if(pressedButtonValue == 'C'){
        //When the clear button is pressed
        onClearPressed();
      } else {
        //When the digits are pressed
        _operation += pressedButtonValue;
      }
    });
  }

  /*
  This method sets the operation to the empty String.
  It is used when the clear buttonn is pressed
  */
  void onClearPressed(){
    //Set the operation to the empty String
    _operation = '';
  }

  /*
  This method ensures we write valid decimal numbers.
  It is used when the dot button is pressed
  */
  void onPointPressed(){
    if(_operation.length == 0 ||
        _operators.sublist(2, _operators.length).contains(_operation[_operation.length - 1]) ||
        _operation[_operation.length - 1] == '('){
          //If the operation is empty or the last element is an operator or an opening bracket,
          //Then precede the '.' with a 0
      _operation += '0.';
    } else {
      if(_operation[_operation.length - 1] != '.'){
        //The last element is not a '.'

        List<String> operationSoFar = getOperationAsList();
        //This ensures there is no more than a single dot in one number
        if(!operationSoFar[operationSoFar.length - 1].contains('.') && 
        operationSoFar[operationSoFar.length - 1] != ')'){
          _operation += '.';
        }
        
      }
    }
  }

  /*
  This method ensures we write valid operations within brackets. 
  It handles the opening and the closing of brackets given that there is only one button for both types of brackets
  It is used when the brackets button is pressed
  */
  void onBracketsPressed(){
    //Keep track of the opening brackets
    List<String> openBracketsList = List<String>();

    //This shows the number of brackets left open
    for(int i = 0; i < _operation.length; i++){

      //If it's an opening bracket, add it to the list 
      //and remove one if it's a closing bracket
      if(_operation[i] == '('){
        openBracketsList.add('(');
      } else if (_operation[i] == ')'){
        openBracketsList.removeLast();
      }
    }
    if(openBracketsList.isEmpty){
      //All the brackets are closed, then this new one should be an opening bracket
      if(_operation.length == 0 ||
          _operators.sublist(2, _operators.length).contains(_operation[_operation.length - 1])){
        //If the last element in the operation is an operator, 
        //then simply add an opening bracket
        _operation += '(';
      } else {
        //If the last element is a number, 
        //then precede the opening bracket with a multiplication sign
        _operation += '*(';
      }
    } else {
      //There are unclosed brackets
      if(_digits.contains(_operation[_operation.length - 1]) ||
          _operation[_operation.length - 1] == ')'){
        //If the last element is a number or a closing bracket, then add a closing bracket
        _operation += ')';
      } else {
        //If last element is an operator, then add one more opening bracket
        _operation += '(';
      }
    }
  }

  /*
  This method ensures we can update the operation by removing numbers or operators. 
  It is used when the delete button is pressed
  */
  void _removeFromOperation() {
    setState(() {
      //Simply cut the last element in operation
      _operation = _operation.substring(0, _operation.length - 1);
    });
  }

  /*
  This method returns the string operation as a list containing the numbers and the operators
  */
  List<String> getOperationAsList(){
    //List to store elements of operation
    List<String> operationList = List<String>();

    //This populates the list
    for(int i = 0; i < _operation.length; i++){
      if((_operators.contains(_operation[i]) ||
          _operation[i] == '(' || _operation[i] == ')') && _operation[i] != '-'){
        //Add a bracket as a single element
        operationList.add(_operation[i]);
      } else {
        //For numbers, we get all the digits that make up the number
        int j = 1;
        String currentNumber = _operation[i];

        //This builds up the number
        while(i + j < _operation.length &&
            (_digits.contains(_operation[i + j]) ||
                _operation[i + j] == '.')){
          currentNumber += _operation[i + j];
          j++;
        }
        operationList.add(currentNumber);
        i += j - 1;
      }
    }

    return operationList;
  }

  /*
  This method shows the result of the operation on a new line
  */
  void _displayResult() {
    String result = performCalculation(getOperationAsList()).toString();
    if(result[result.length - 1] == '0' && result[result.length - 2] == '.'){
      //When the result is an integer
      result = result.substring(0, result.length - 2);
    }

    if(result == 'Infinity'){
      //In case, there is a division by 0
      setState(() {
        showDialog(
          context: this.context,
          builder: (BuildContext context){
            return AlertDialog(
              title: Text('Math error !'),
              content: Text('Cannot divide by zero'),
            );
          }
        );
      });
    } else {
      //Show operation on one line and result on the next line
      setState(() {
        _operation = _operation + "\n" + result;
      });
    }
      
  }

  /*
  This method creates an InfixOperator object and returns the result of the operation
  */
  double performCalculation(List<String> operationAsList){
    //Initialize an InfixOperator object
    InfixOperator infixOperator = InfixOperator();

    return infixOperator.evaluateOperation(operationAsList);
  }

  /*
  This is the build method of this class; it renders all the widgets that make up the application
  */
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Column(
        children: <Widget>[          
          Container(
            child: Text(
              _operation, 
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 50.0, 
                fontWeight: FontWeight.w300
                )
              ),
            alignment: Alignment.bottomRight,
            color: Colors.blueGrey,
            height: 250.0,
            padding: EdgeInsets.all(10.0),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              color: Colors.grey,
              child: getButtons(_buttonValues),
              padding: EdgeInsets.all(10.0),
            )
          ),
        ],
      ),
    );
  }

  /*
  This method returns the different buttons in our calculator as widgets.
  It creates buttons using appropriate values and places them
  */
  Widget getButtons(List<String> buttonValues){
    //The buttons are created as a row of four columns
    //This is a list containing the four column widgets
    List<Widget> columnList = new List<Widget>();

    //This populates the list of columns with button widgets
    for(int i = 0; i < buttonValues.length; i += 5){
      //Each column contains 5 or 4 buttons 
      //This list contains the buttons for a single column
      List<Widget> buttonsList = new List<Widget>();

      //This populates the list of buttons
      for(int j = 0; j < 5 && i + j < buttonValues.length - 1; j++){
        //Intialize a RaisedButton
        RaisedButton button;

        //Given the value of the button, use appropriate callback function
        if(buttonValues[i + j] == 'DEL'){
          button = RaisedButton(
            child: Text(buttonValues[i + j]),
            onPressed: (){_removeFromOperation();},
            color: Colors.blueGrey,
          );
        } else {
          if(_operators.contains(buttonValues[i + j])){
            button = RaisedButton(
              child: Text(buttonValues[i + j]),
              onPressed: () {
                _addToOperation(buttonValues[i + j]);
              },
              color: Colors.black54,
            );
          } else {
            button = RaisedButton(
              child: Text(buttonValues[i + j]),
              onPressed: () {
                _addToOperation(buttonValues[i + j]);
              },
              color: Colors.blueGrey,
            );
          }
        }

        buttonsList.add(button);
      }

      //Special case for the equal button, so it has a different look
      if(i == 15){
        RaisedButton button = RaisedButton(
          child: Text(buttonValues[buttonValues.length - 1]),
          onPressed: (){_displayResult();},
          color: Colors.deepOrange,
        );
        columnList.add(Expanded(
            child: Column(
                children: [
                  Flexible(child: Column(children: buttonsList, mainAxisAlignment: MainAxisAlignment.spaceEvenly), flex: 3),
                  Expanded(child: button, flex: 2,)
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween
            )
        ));
      } else {
        columnList.add(Expanded(
            child: Column(
                children: buttonsList,
                mainAxisAlignment: MainAxisAlignment.spaceAround
            )
        ));
      }

    }
    //Return a row whose children are the 4 columns previously created
    return Row(children: columnList);
  }
}