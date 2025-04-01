const { employees, species } = require('../data/zoo_data');

function getOldestFromFirstSpecies(id) {
  return species.find((specie) => (specie.id === employees.find((employee) => (employee.id === id)).responsibleFor[0]
  )).residents.sort((a, b) => b.age - a.age).map((animal) => ([animal.name, animal.sex, animal.age]))[0];
}

module.exports = getOldestFromFirstSpecies;
