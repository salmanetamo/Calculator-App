/*
Author: Salmane Tamo
Date: 18/11/2018

Description: The InfixOperator class allows us to evaluate the final result of a given operation.
It follows the BODMAS rules, giving priority to parentheses, then multiplication and division, 
and addition and substraction at last.
*/
class InfixOperator{

  /*
  This method works recursively to perform the calculation and returns the final result as a double.
  
  Parameter: operationAsList -> List containing the operands and operators of the operation
  Return: double -> result of the operation
  */
  double evaluateOperation(List<String> operationAsList){

    if(operationAsList.length == 1){

      //Base case: this returns the final result
      return double.parse(operationAsList[0]);

    } else if(operationAsList.length == 3){

      //Only one operation is performed and result is returned
      return _calculate(operationAsList[0], operationAsList[2], operationAsList[1]);

    } else if(!operationAsList.contains('(')){
      //Case where there are no parentheses, then follow precedence rules

      List<int> priority1OperatorsIndices = _getOperatorsIndices(operationAsList);

      if(priority1OperatorsIndices.length == 0){
        //No multiplication or division need to be performed
        //Perform calculation from left to right

        //Use first two operands and operator to get a result
        double firstOperation = _calculate(operationAsList[0], operationAsList[2], operationAsList[1]);
        
        //Remove elements already used from the list
        operationAsList.removeAt(0);
        operationAsList.removeAt(0);
        operationAsList.removeAt(0);

        //Put the result of the calculation back in the list at the first position
        operationAsList.insert(0, firstOperation.toString());

        return evaluateOperation(operationAsList);
      } else {
        //Perform multiplication and division first until they are finished

        //Get index of operands and the multiplication or division sign
        int indexOperand1 = priority1OperatorsIndices[0] - 1;
        int indexOperand2 = priority1OperatorsIndices[0] + 1;
        int indexOperator = priority1OperatorsIndices[0];

        //Use those operands to get a result
        double firstOperation = _calculate(operationAsList[indexOperand1], operationAsList[indexOperand2], operationAsList[indexOperator]);
 
        //Remove elements already used from the list
        operationAsList.removeAt(indexOperand1);
        operationAsList.removeAt(indexOperand1);
        operationAsList.removeAt(indexOperand1);

        //Put the result of the calculation back in the list at the index of the first operand
        operationAsList.insert(indexOperand1, firstOperation.toString());

        return evaluateOperation(operationAsList);
      }
    } else {
      //There are parentheses, so perform operations in parentheses first

      //This map stores the different operations within parentheses along with their index
      Map<int, List<String>> elementsInBrackets = _getElementsInBrackets(operationAsList);

      //This is the first operation in brackets that will be evaluated
      List<String> firstOperation = List<String>();
      int firstOperationIndex = 0;

      //This gets that first operation from the map
      for(int i = 0; i < operationAsList.length; i++){
        if(elementsInBrackets.containsKey(i)){
          firstOperation = elementsInBrackets[i];
          firstOperationIndex = i;
        }
      }

      //This removes the elements already used from the list
      for(int i = firstOperationIndex; i < firstOperation.length + firstOperationIndex; i++){
        operationAsList.removeAt(firstOperationIndex);
      }
      
      //This removes the opening and closing brackets from the operation
      firstOperation.removeAt(0);
      firstOperation.removeLast();

      //This gets the result from computing the operation within the brackets
      double firstOperationResult = evaluateOperation(firstOperation);

      //The result is added in the list at the position of the initial opening bracket
      operationAsList.insert(firstOperationIndex, firstOperationResult.toString());

      return evaluateOperation(operationAsList);
    }
  }


  /*
  This method identifies the multiplication and division signs in the operation.

  Parameter: operationAsList -> List containing the operands and operators of the operation
  Return: List<int> -> List containing the indices of the multiplication and division signs
  */
  List<int> _getOperatorsIndices(List<String> operationAsList){
    if(!(operationAsList.contains('*') || operationAsList.contains('/'))){
      //There are no multiplication or division signs, return the empty list
      return [];
    }

    //Create list to store the indices of the multiplication or division signs
    List<int> indicesList = List<int>();

    //This adds the index to the list each time either of the signs is found
    for(int i = 0; i < operationAsList.length; i++){
      if(operationAsList[i] == '*' || operationAsList[i] == '/'){
        indicesList.add(i);
      }
    }

    return indicesList;
  }


  /*
  This method finds the operations within brackets.

  Parameter: operationAsList -> List containing the operands and operators of the operation
  Return: Map<int, List<String>> -> Map containing the operations within brackets and their index
  */
  Map<int, List<String>> _getElementsInBrackets(List<String> operationAsList){

    //Create a map to store the operations within parentheses
    Map<int, List<String>> elementsInBrackets = Map<int, List<String>>();

    int openBracketsCount = 0;  //Number of opening brackets
    int lastClosingBracketIndex = operationAsList.indexOf('(');  //Index of latest closing bracket
    
    //This ensures the operations within parentheses are added to the map along with their indices
    for(int i = 0; i < operationAsList.length; i++){
      if(operationAsList[i] == '('){
        //Opening bracket found, increment the counter
        openBracketsCount += 1;
      } else if(operationAsList[i] == ')'){
        //Opening bracket found, decrement the counter
        openBracketsCount -= 1;

        if(openBracketsCount == 0){
          //Opening brackets count is zero, we have finally closed an operation within parentheses

          //Getting the index of the opening bracket of this operation
          int openingBracketindex = operationAsList.sublist(lastClosingBracketIndex, i + 1).indexOf('(') + lastClosingBracketIndex;

          //Storing the operation within the brackets in a list including the brackets themselves
          List<String> singleBracketsElements = operationAsList.sublist(openingBracketindex, i + 1);

          //Adding the list to the map with its key being the index of its opening bracket
          elementsInBrackets[openingBracketindex] = singleBracketsElements;

          //Latest closing bracket is the current element we are looking at
          lastClosingBracketIndex = i;
        }
      }
    }

    return elementsInBrackets;
  }


  /*
  This method performs a single basic operation and returns the result.

  Parameters: operand1 -> First value
              operand2 -> Second value
              operator -> Operator
  Return: double -> result of the operation
  */
  double _calculate(String operand1, String operand2, String operator){
    //Turning the two operands into doubles
    double op1 = double.parse(operand1);
    double op2 = double.parse(operand2);

    //Depending on the operator, perform calculation accordingly and return result
    if(operator == '+'){
      return op1 + op2;
    } else if(operator == '-'){
      return op1 - op2;
    } else if(operator == '*'){
      return op1 * op2;
    } else {
      return op1/op2;
    }
  }
}