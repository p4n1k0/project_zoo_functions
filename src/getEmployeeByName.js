const { employees } = require('../data/zoo_data');

function getEmployeeByName(employeeName) {
  if (!employeeName) { // Retorna objeto vazio caso não receba parâmetros
    return {};
  }
  return employees.find((employee) => ( // Assim que encontra primeiro nome do funcionário ou último nome do funcionário, retona o objeto do funcionário
    employee.firstName === employeeName
    || employee.lastName === employeeName
  ));
}

module.exports = getEmployeeByName;
