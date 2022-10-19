const { employees, species } = require('../data/zoo_data');

function getOldestFromFirstSpecies(id) { // Cria variável para armazenar primeiro animal que é gerenciado pelo funcionário do id passado como parâmetro
  const employeeAnimal = employees.find((employee) => (
    employee.id === id
  )).responsibleFor[0];
  const firstOldest = species.find((specie) => ( // Cria variável para atribuir um array com o nome, sexo e idade do animal mais velho da espécie
    specie.id === employeeAnimal
  )).residents.sort((a, b) => b.age - a.age).map((animal) => (
    [animal.name, animal.sex, animal.age]
  ))[0];

  return firstOldest;
}

module.exports = getOldestFromFirstSpecies;
