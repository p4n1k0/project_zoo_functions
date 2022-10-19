const { employees } = require('../data/zoo_data');

function isManager(id) { // Função para retornar true se funcionário for um gerente e false, caso contrário
  return employees.some(({ managers }) => (
    managers.find((manager) => (
      manager === id
    ))
  ));
}

function getRelatedEmployees(managerId) {
  if (!isManager(managerId)) {
    throw new Error('O id inserido não é de uma pessoa colaboradora gerente!');// Dispara erro, caso funcionário não for um gerente
  }
  return employees.filter(({ managers }) => (
    managers.some((manager) => (
      manager === managerId
    ))
  )).map(({ firstName, lastName }) => (`${firstName} ${lastName}`)); // Retorna um array com o nome e sobrenome dos funcionários gerenciados por determinado gerente
}

module.exports = { isManager, getRelatedEmployees };
