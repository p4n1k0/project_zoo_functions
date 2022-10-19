const { species } = require('../data/zoo_data');

function getAnimalsOlderThan(animal, age) {
  return species.find(({ name }) => (
    name === animal)).residents.every(({ age: residentAge }) => (
    residentAge >= age
  )); // buscando nome de espécie animal e testa se todos animais desta espécie possui idade mínima
}

module.exports = getAnimalsOlderThan;
